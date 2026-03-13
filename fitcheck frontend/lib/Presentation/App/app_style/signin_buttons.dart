import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuth {
  static final _supabase = Supabase.instance.client;

  static Future<void> signInWithGoogle(BuildContext context) async {
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
      );
    } else {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    }

   
  }
}


class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
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