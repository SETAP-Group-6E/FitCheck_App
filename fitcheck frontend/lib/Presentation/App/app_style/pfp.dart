// Small profile picture widget used across the app where a compact
// avatar is required. Falls back to a generic person icon when no URL
// is provided. The `onUpload` callback is kept for API parity with
// components that may handle uploads.
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  Widget build(BuildContext context) {
    // A tiny avatar used in lists and compact controls. We intentionally
    // avoid additional layout complexity — it's a fixed-size container
    // that shows either the network image or a simple placeholder.
    return SizedBox(
      width: 20,
      height: 20,
      child: Container(
        child:
            imageUrl != null
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.black54, size: 10),
                  ),
                ),
      ),
    );
  }
}
