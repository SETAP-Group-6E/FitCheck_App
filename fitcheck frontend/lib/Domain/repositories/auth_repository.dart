abstract class AuthRepository {
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<void> signIn({
    required String email, 
    required String password
  });
}
