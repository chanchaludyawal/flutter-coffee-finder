// lib/core/errors/auth_exception.dart

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';

  factory AuthException.fromFirebase(String code) {
    return switch (code) {
      'user-not-found' => const AuthException(
        'No account found with this email.',
        code: 'user-not-found',
      ),
      'wrong-password' => const AuthException(
        'Incorrect password.',
        code: 'wrong-password',
      ),
      'email-already-in-use' => const AuthException(
        'This email is already registered.',
        code: 'email-already-in-use',
      ),
      'invalid-email' => const AuthException(
        'Email address is not valid.',
        code: 'invalid-email',
      ),
      'network-request-failed' => const AuthException(
        'No internet connection.',
        code: 'network-request-failed',
      ),
      'too-many-requests' => const AuthException(
        'Too many attempts. Try again later.',
        code: 'too-many-requests',
      ),
      'account-exists-with-different-credential' => const AuthException(
        'Account exists with a different sign-in method.',
      ),
      _ => AuthException('Something went wrong. ($code)'),
    };
  }
}
