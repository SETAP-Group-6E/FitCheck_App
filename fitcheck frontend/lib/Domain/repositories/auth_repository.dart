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
