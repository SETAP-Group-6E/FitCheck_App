// ProfilePicture: small avatar that supports picking, cropping, and
// uploading a new profile picture. Tap triggers image selection and
// crop flow; after upload the `onUpload` callback is called with the
// public URL.
import 'dart:typed_data';

import 'package:fitcheck/Presentation/App/app_pages/posts/crop_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/app_toast.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key, this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool _uploading = false;

  Future<void> _pickCropAndUpload() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    // Open crop page and get cropped bytes
    final cropped = await Navigator.of(context).push<Uint8List?>(
      MaterialPageRoute(builder: (_) => CropPage(imageBytes: bytes, startCropping: true)),
    );
    if (cropped == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showAppMessage(context, 'Please sign in to change your profile picture.');
      return;
    }

    setState(() => _uploading = true);
    try {
      final bucket = Supabase.instance.client.storage.from('Avatars');
      final path = '${user.id}/avatar.jpg';
      await bucket.uploadBinary(path, cropped, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
      final publicUrl = bucket.getPublicUrl(path);
      widget.onUpload(publicUrl);
      showAppMessage(context, 'Profile picture updated');
    } catch (e) {
      showAppMessage(context, 'Avatar upload failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: _uploading ? null : _pickCropAndUpload,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.imageUrl != null
                  ? Image.network(widget.imageUrl!, fit: BoxFit.cover, width: 40, height: 40)
                  : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.person, color: Colors.black54, size: 18)),
                    ),
            ),
            if (_uploading)
              Container(
                width: 40,
                height: 40,
                color: Colors.black45,
                child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
              ),
          ],
        ),
      ),
    );
  }
}
