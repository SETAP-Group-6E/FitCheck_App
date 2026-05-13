// PostCommentTile: compact comment display used in comment lists and
// the comments sheet. Shows avatar, username, time label and message.
import 'package:flutter/material.dart';

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({super.key, required this.username, required this.body, this.timeLabel, this.profileImageUrl});

  final String username;
  final String body;
  final String? timeLabel;
  final String? profileImageUrl;
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Avatar: if a profile image URL is provided we show a
            // NetworkImage; otherwise a simple placeholder avatar is
            // displayed. Radius and sizes are small to keep list rows
            // compact.
            profileImageUrl != null && profileImageUrl!.isNotEmpty
              ? CircleAvatar(radius: 14, backgroundColor: Colors.white24, backgroundImage: NetworkImage(profileImageUrl!))
              : const CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    if (timeLabel != null) Text(timeLabel!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment body: allow natural wrapping and use a slightly
                // muted color to distinguish it from the username line.
                Text(body, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
