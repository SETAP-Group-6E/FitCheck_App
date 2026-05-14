// File: lib/Domain/repositories/auth_repository.dart
// Purpose: Authentication repository interface.
// Notes: Implementations handle sign-in and sign-up workflows.

abstract class AuthRepository {
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  });
  Future<void> signIn({
    required String email, 
    required String password
  });
}
