import 'package:fitcheck/Presentation/App/app_style/password_field.dart';
import 'package:fitcheck/Presentation/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/auth_provider.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(child: SizedBox()),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromRGBO(217, 156, 19, 1),
                  ),
                  child: Image(image: AssetImage("Assets/logo_white.png")),
                ),
              ),
              SizedBox(height: 20),

              Text(
                "Join the Community",
                style: GoogleFonts.dmSerifText(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Discover and share your daily style",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 350,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: 350,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 40, width: 350, child:PasswordField(passwordController)),
              SizedBox(height: 10),

              SizedBox(
                height: 40,
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(217, 156, 19, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () async {
                    final authRepo = ref.read(authRepositoryProvider);                
                    try {         
                      await authRepo.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        name: nameController.text.trim(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success! Check your email.')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 35,
                    width: 35,
                    child: GestureDetector(
                      onTap: () {
                        null;
                      },
                      child: Image(image: AssetImage("Assets/google_logo.png")),
                    ),
                  ),
                  SizedBox(width: 25),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(217, 156, 19, 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 35,
                    width: 35,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.apple, color: Colors.black, size: 30),
                      onPressed: () {
                        null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LoginPage(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            var begin = Offset(-1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(color: Color.fromRGBO(217, 156, 19, 1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(child: SizedBox(
            child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
          )),
        ],
      ),
    );
  }
}
