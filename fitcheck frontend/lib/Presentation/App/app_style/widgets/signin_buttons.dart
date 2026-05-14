// OAuth helpers and small sign-in buttons.
// - `GoogleAuth` encapsulates signing in using Supabase's OAuth flow.
// - `GoogleSignInButton` is a compact circular button used in places
//   where a minimal social sign-in affordance is desired.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuth {
  // Supabase client instance used for OAuth operations.
  static final _supabase = Supabase.instance.client;

  /// Trigger Google OAuth sign-in. On web, the standard redirect flow
  /// is used; on mobile we provide a custom redirect URI that the app
  /// handles after the OAuth callback.
  static Future<void> signInWithGoogle(BuildContext context) async {
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
      );
    } else {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // The redirect URI should be registered in your Supabase
        // project and mapped to the app's deep link handler.
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    }
  }
}


class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    // A compact circular white button showing the Google logo. It
    // delegates the sign-in flow to `GoogleAuth.signInWithGoogle`.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
      ),
      height: 35,
      width: 35,
      child: ClipOval(
        child: ElevatedButton(
          onPressed: () async {
            await GoogleAuth.signInWithGoogle(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: EdgeInsets.all(0),
          ),
          child: Image.asset("Assets/google_logo.png"),
        ),
      ),
    );
  }
}

// flutter run -d chrome --web-port 62597