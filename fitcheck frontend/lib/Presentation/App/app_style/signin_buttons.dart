import 'dart:async';
import 'dart:io';

import 'package:fitcheck/Presentation/auth/pages/register_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> _signInWithGoogle() async {
    const webClientId =
        '710981741624-td03q93d5mp31s88okuc8q4uk0i8ugm3.apps.googleusercontent.com';

    const iosClientId =
        '710981741624-024pa5pt8bp8osske6r43sbfs3dit0as.apps.googleusercontent.com';

    final GoogleSignIn signIn = GoogleSignIn.instance;

    unawaited(
      signIn.initialize(clientId: iosClientId, serverClientId: webClientId),
    );

    final googleAccount = await signIn.authenticate();
    final googleAuthorization = await googleAccount.authorizationClient
        .authorizationForScopes([]);
    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    final accessToken = googleAuthorization?.accessToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

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
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
              return _signInWithGoogle();
            }

            await supabase.auth.signInWithOAuth(OAuthProvider.google);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: CircleBorder(),
            padding: EdgeInsets.all(0),
          ),
          child: Image(image: AssetImage("Assets/google_logo.png")),
        ),
      ),
    );
  }
}
