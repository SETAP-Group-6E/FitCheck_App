import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart' as sn;
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppThemeMode {
  moody,
  pale,
}

class AppThemeModeController extends sn.StateNotifier<AppThemeMode> {
  AppThemeModeController() : super(AppThemeMode.moody) {
    _hydrateFromCurrentUser();
    _authSub = _supabase.auth.onAuthStateChange.listen((event) {
      _hydrateFromCurrentUser();
    });
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  bool get _isAuthenticated {
    return _supabase.auth.currentSession != null &&
        _supabase.auth.currentUser != null;
  }

  void _hydrateFromCurrentUser() {
    if (!_isAuthenticated) {
      state = AppThemeMode.moody;
      return;
    }

    final modeValue =
        _supabase.auth.currentUser?.userMetadata?['theme_mode'] as String?;

    if (modeValue == 'pale') {
      state = AppThemeMode.pale;
      return;
    }

    state = AppThemeMode.moody;
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (!_isAuthenticated) {
      state = AppThemeMode.moody;
      return;
    }

    final user = _supabase.auth.currentUser!;

    state = mode;

    final metadata = Map<String, dynamic>.from(user.userMetadata ?? {});
    metadata['theme_mode'] = mode.name;

    try {
      await _supabase.auth.updateUser(UserAttributes(data: metadata));
    } catch (_) {
      // Keep local state even if metadata update fails.
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeController, AppThemeMode>((ref) {
  return AppThemeModeController();
});

ThemeData buildAppTheme(AppThemeMode mode) {
  final scaffoldColor =
      mode == AppThemeMode.moody ? Colors.black : const Color(0xFF454645);

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: scaffoldColor,
  );
}
