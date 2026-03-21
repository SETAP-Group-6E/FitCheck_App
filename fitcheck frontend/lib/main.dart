import 'package:fitcheck/Presentation/App/app_pages/h_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/home_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe_page.dart';
import 'package:fitcheck/Presentation/auth/pages/login_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Presentation/auth/pages/register_page.dart';
//import 'Presentation/app/app_pages/wardrobe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  const supabaseUrl = 'https://fsjkselzckrheqtqvzze.supabase.co';
  const supabaseAnonKey = 'sb_publishable_Qt6ShYvhFsUlQ4fY_LFl6A_aRLJ4Jnr';
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitCheck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      
      
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/homepage':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 220),
              reverseTransitionDuration: const Duration(milliseconds: 180),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          case '/hpage':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 220),
              reverseTransitionDuration: const Duration(milliseconds: 180),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          case '/register':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 280),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RegisterPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slideTween = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutQuart));

                return SlideTransition(
                  position: animation.drive(slideTween),
                  child: child,
                );
              },
            );
          case '/login':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 280),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slideTween = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutQuart));

                return SlideTransition(
                  position: animation.drive(slideTween),
                  child: child,
                );
              },
            );
          case '/settings':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 280),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SettingsPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slideTween = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic));

                return SlideTransition(
                  position: animation.drive(slideTween),
                  child: child,
                );
              },
            );
          case '/wardrobe':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 220),
              reverseTransitionDuration: const Duration(milliseconds: 180),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const WardrobePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final fadeCurve = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );

                return FadeTransition(
                  opacity: fadeCurve,
                  child: child,
                );
              },
            );
          default:
            return null;
        }
      },
    );
  }
}

// flutter run -d chrome --web-port 62597
