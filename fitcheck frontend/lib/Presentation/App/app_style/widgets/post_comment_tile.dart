// PostCommentTile: compact comment display used in comment lists and
// the comments sheet. Shows avatar, username, time label and message.
import 'package:flutter/material.dart';

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({
    super.key,
    required this.username,
    required this.body,
    this.timeLabel,
    this.profileImageUrl,
    this.isOwn = false,
    this.onDelete,
  });

  final String username;
  final String body;
  final String? timeLabel;
  final String? profileImageUrl;
  final bool isOwn;
  final VoidCallback? onDelete;

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
              ? CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white24,
                backgroundImage: NetworkImage(profileImageUrl!),
              )
              : const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (timeLabel != null)
                      Text(
                        timeLabel!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment body: allow natural wrapping and use a slightly
                // muted color to distinguish it from the username line.
                Text(body, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          // If this comment belongs to the current user show a small
          // delete button aligned to the right. This keeps the tile
          // compact while enabling deletion affordance.
          if (isOwn)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              color: const Color(0xFF121212),
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white54,
                size: 18,
              ),
              onSelected: (v) async {
                if (v == 'delete') {
                  final confirmed =
                      await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF121212),
                              title: Text(
                                'Delete comment',
                                style: Theme.of(ctx).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOwn
                                        ? 'Delete this comment?'
                                        : 'Delete comment from $username?',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      body.length > 180
                                          ? '${body.substring(0, 180)}…'
                                          : body,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Color(0xFFD99C13)),
                                  ),
                                ),
                              ],
                            ),
                      ) ??
                      false;
                  if (confirmed) onDelete?.call();
                }
              },
              itemBuilder:
                  (ctx) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
    );
  }
}
