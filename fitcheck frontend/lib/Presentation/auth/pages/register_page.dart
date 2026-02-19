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

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

Container(
  height: 120,
  width: 120,
  decoration: const BoxDecoration(
    color: Color(0xFFD4AF37),
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



            _buildGoldInput(
  controller: nameController,
  hint: "User name",
),

            _buildGoldInput(
  controller: emailController,
  hint: "Email",
),
            _buildGoldInput(
  controller: passwordController,
  hint: "Password",
  obscure: true,
),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {

                final authRepo = ref.read(authRepositoryProvider);
                
                try {
         
                  await authRepo.signUp(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success! Check your email.')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Test Register'),
            ),
          ],
        ),
      ),
    ),
  );
  
  }
}
  