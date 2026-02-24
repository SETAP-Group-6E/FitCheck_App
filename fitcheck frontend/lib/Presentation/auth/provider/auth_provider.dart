import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Domain/repositories/auth_repository.dart';
import '../../../Data/repositories/supabase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  return SupabaseAuthRepository(supabaseClient);
});

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController();
});
