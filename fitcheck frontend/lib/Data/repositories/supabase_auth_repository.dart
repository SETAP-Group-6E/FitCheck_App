import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _supabase.from('profiles').insert({
        'profile_id': userId, 
        'full_name': name,
        'email': email,
      });
    }
  }
  @override
  Future<void> signIn({
    required String email, 
    required String password
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}
