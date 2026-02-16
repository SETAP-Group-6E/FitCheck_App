import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/auth_provider.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    const gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 40),

              /// Logo Circle
              Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ///  Title
              const Text(
                "Join the community",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Discover and share your daily style",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              ///  Username
              _buildGoldInput(
                controller: nameController,
                hint: "User name",
              ),

              const SizedBox(height: 16),

              /// Email
              _buildGoldInput(
                controller: emailController,
                hint: "Email",
              ),

              const SizedBox(height: 16),

              /// Password
              _buildGoldInput(
                controller: passwordController,
                hint: "Password",
                obscure: true,
              ),

              const SizedBox(height: 30),

              ///  Create Account Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final authRepo = ref.read(authRepositoryProvider);

                    try {
                      await authRepo.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Success! Check your email.'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ///  Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialCircle(Icons.g_mobiledata),
                  const SizedBox(width: 20),
                  _buildSocialCircle(Icons.apple),
                ],
              ),

              const SizedBox(height: 30),

              ///  Login Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Already have your account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Log in",
                    style: TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  ///  Gold Styled Input
  static Widget _buildGoldInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    const gold = Color(0xFFD4AF37);

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1C1F2E),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
      ),
    );
  }

  ///  Social Icon Circle
  static Widget _buildSocialCircle(IconData icon) {
    const gold = Color(0xFFD4AF37);

    return Container(
      height: 50,
      width: 50,
      decoration: const BoxDecoration(
        color: gold,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
