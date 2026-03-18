import 'package:fitcheck/Presentation/auth/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitcheck/Presentation/App/app_style/pfp.dart';
class HPage extends StatelessWidget {
  const HPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to FitCheck!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(217, 156, 19, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/wardrobe');
                },
                child: const Text('Go to Wardrobe'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(217, 156, 19, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final supabase = Supabase.instance.client;
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null) {
                    return;
                  }

                  final imageBytes = await image.readAsBytes();
                  final userId = supabase.auth.currentUser?.id;
                  if (userId == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No logged in user found')),
                      );
                    }
                    return;
                  }

                  final imagePath = '$userId/avatar.jpg';

                  try {
                    await supabase.storage.from('Avatars').uploadBinary(
                      imagePath,
                      imageBytes,
                      fileOptions: const FileOptions(
                        contentType: 'image/jpeg',
                        upsert: true,
                      ),
                    );

                    final imageUrl = supabase.storage
                        .from('Avatars')
                        .getPublicUrl(imagePath);

                    ProfilePicture(
                      onUpload: (imageUrl) async {
                        await supabase
                            .from('profiles')
                            .update({'avatar_url': imageUrl})
                            .eq('id', userId);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Uploaded to Avatars/$imagePath',
                              ),
                            ),
                          );
                        }
                      },
                    ).onUpload(imageUrl);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload failed: $e')),
                      );
                    }
                  }
                },
                child: const Text('upload pfp'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(217, 156, 19, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Go to sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
