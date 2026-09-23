// lib/data/repositories/user_repository_impl.dart

import 'package:cuproute/core/error/auth_exception.dart';
import 'package:cuproute/core/storage/hive_service.dart';
import 'package:cuproute/core/storage/secure_storage.dart';
import 'package:cuproute/domain/entities/user_entity.dart';
import 'package:cuproute/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  // ════════════════════════════════════════════════════
  //  GET CURRENT USER
  // ════════════════════════════════════════════════════
  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      // No Firebase session → return Hive cache if available
      if (firebaseUser == null) {
        if (!HiveService.hasUser()) return null; // ← your hasUser()
        return _entityFromHive();
      }

      // Firebase session alive → refresh token, sync storage
      final idToken = await firebaseUser.getIdToken(true);

      await SecureStorageService.saveAuthTokens(
        uid: firebaseUser.uid,
        idToken: idToken ?? '',
        refreshToken: firebaseUser.refreshToken ?? '',
      );

      // Update Hive profile cache with your saveUser()
      await HiveService.saveUser(
        // ← your saveUser()
        id: firebaseUser.uid,
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Coffee lover',
        avatarUrl: firebaseUser.photoURL,
      );

      return _entityFromFirebase(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code);
    } catch (_) {
      // Network down → serve Hive cache so app still works offline
      if (HiveService.hasUser()) return _entityFromHive(); // ← your hasUser()
      return null;
    }
  }

  // ════════════════════════════════════════════════════
  //  IS LOGIN USER
  //  Derived — never read a stored bool
  // ════════════════════════════════════════════════════
  @override
  Future<bool> isLoginUser() async {
    // Primary → Firebase session
    if (_firebaseAuth.currentUser != null) return true;

    // Fallback → check secure storage token
    // handles edge case where Firebase hasn't rehydrated yet on cold start
    return SecureStorageService.hasSession();
  }

  // ════════════════════════════════════════════════════
  //  LOGIN WITH GOOGLE
  // ════════════════════════════════════════════════════
  @override
  Future<UserEntity> loginWithGoogle() async {
    try {
      // 1. Google picker
      final googleUser = await _googleSignIn.authenticate();

      // 2. Get Google tokens
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // 3. Firebase sign-in
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user!;
      final idToken = await user.getIdToken();

      // 4. Secrets → secure storage
      await SecureStorageService.saveAuthTokens(
        uid: user.uid,
        idToken: idToken ?? '',
        refreshToken: user.refreshToken ?? '',
      );

      // 5. Profile → your HiveService.saveUser()
      await HiveService.saveUser(
        // ← your saveUser()
        id: user.uid,
        firebaseUid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Coffee lover',
        avatarUrl: user.photoURL,
      );

      return _entityFromFirebase(user);
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          throw const AuthException('Google sign-in was cancelled.');
        case GoogleSignInExceptionCode.interrupted:
          throw const AuthException('Google sign-in was interrupted.');
        default:
          throw AuthException('Google sign-in failed: ${e.code}');
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  // ════════════════════════════════════════════════════
  //  LOGIN WITH EMAIL + PASSWORD
  // ════════════════════════════════════════════════════
  @override
  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user!;
      final idToken = await user.getIdToken();

      await SecureStorageService.saveAuthTokens(
        uid: user.uid,
        idToken: idToken ?? '',
        refreshToken: user.refreshToken ?? '',
      );

      await HiveService.saveUser(
        // ← your saveUser()
        id: user.uid,
        firebaseUid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Coffee lover',
        avatarUrl: user.photoURL,
      );

      return _entityFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code);
    } catch (_) {
      throw const AuthException('Login failed. Please try again.');
    }
  }

  // ════════════════════════════════════════════════════
  //  LOGIN WITH FACEBOOK
  // ════════════════════════════════════════════════════
  @override
  Future<UserEntity> loginWithFacebook() async {
    try {
      // 1. Facebook login
      final result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        throw const AuthException('Facebook sign-in was cancelled.');
      }
      if (result.status != LoginStatus.success) {
        throw const AuthException('Facebook sign-in failed.');
      }

      // 2. Exchange for Firebase credential
      final credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      // 3. Firebase sign-in
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;
      final idToken = await user.getIdToken();

      await SecureStorageService.saveAuthTokens(
        uid: user.uid,
        idToken: idToken ?? '',
        refreshToken: user.refreshToken ?? '',
      );

      await HiveService.saveUser(
        // ← your saveUser()
        id: user.uid,
        firebaseUid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Coffee lover',
        avatarUrl: user.photoURL,
      );

      return _entityFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Facebook sign-in failed. Please try again.');
    }
  }

  // ════════════════════════════════════════════════════
  //  LOGOUT
  // ════════════════════════════════════════════════════
  @override
  Future<void> logout() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      SecureStorageService.clearAuth(),
      HiveService.clearUser(), // ← your clearUser()
      // HiveService.clearSettings() intentionally excluded
      // — filter prefs survive logout
    ]);
  }

  // ════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ════════════════════════════════════════════════════

  /// Build UserEntity from a live Firebase user
  /// — pulls filter prefs from your HiveService getters
  UserEntity _entityFromFirebase(User user) {
    return UserEntity(
      id: user.uid,
      firebaseUid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'Coffee lover',
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      // ── pull prefs from your exact HiveService getters ──
      searchRadiusMetres: HiveService.getSearchRadius(), // ← your getter
      minRating: HiveService.getMinRating(), // ← your getter
      filterWifi: HiveService.getFilterWifi(), // ← your getter
      filterParking: HiveService.getFilterParking(), // ← your getter
      filterOutdoor: HiveService.getFilterOutdoor(), // ← your getter
      sortOrder: SortOrder.values.firstWhere(
        (e) => e.name == HiveService.getSortOrder(), // ← your getter
        orElse: () => SortOrder.distance,
      ),
    );
  }

  /// Build UserEntity from Hive cache — offline fallback
  /// — uses your exact HiveService getters
  UserEntity _entityFromHive() {
    return UserEntity(
      id: HiveService.getUserId() ?? '', // ← your getter
      firebaseUid: HiveService.getUserFirebaseUid() ?? '', // ← your getter
      email: HiveService.getUserEmail() ?? '', // ← your getter
      name: HiveService.getUserName() ?? 'Coffee lover', // ← your getter
      avatarUrl: HiveService.getUserAvatar(), // ← your getter
      createdAt:
          DateTime.tryParse(
            HiveService.getUserCreatedAt() ?? '', // ← your getter
          ) ??
          DateTime.now(),
      searchRadiusMetres: HiveService.getSearchRadius(), // ← your getter
      minRating: HiveService.getMinRating(), // ← your getter
      filterWifi: HiveService.getFilterWifi(), // ← your getter
      filterParking: HiveService.getFilterParking(), // ← your getter
      filterOutdoor: HiveService.getFilterOutdoor(), // ← your getter
      sortOrder: SortOrder.values.firstWhere(
        (e) => e.name == HiveService.getSortOrder(), // ← your getter
        orElse: () => SortOrder.distance,
      ),
    );
  }
}
