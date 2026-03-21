import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  Widget build(BuildContext context) {
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
