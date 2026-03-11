import 'package:fitcheck/Presentation/App/app_pages/home_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe_page.dart';
import 'package:fitcheck/Presentation/auth/pages/login_page.dart';
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
      

      routes: {

        '/homepage': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/wardrobe': (context) => const WardrobePage(),

      }
    );
  }
}

