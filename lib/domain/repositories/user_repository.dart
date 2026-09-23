import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> loginWithGoogle();
  Future<UserEntity> loginWithFacebook();
  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<bool> isLoginUser();
  Future<void> logout();
}
