// File: lib/Presentation/App/app_pages/notifications_page.dart
// Purpose: Simple notifications list showing likes and comment previews.
// Notes: Allows marking all as read which updates user metadata.

import 'package:flutter/material.dart';
import 'package:fitcheck/Data/repositories/notification_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/profile/my_posts_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final repo = NotificationRepository();
  bool _loading = true;
  List<NotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await repo.fetchNotifications(limit: 200);
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _markAllRead() async {
    await repo.markAllRead();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('Mark all read', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No notifications', style: TextStyle(color: Colors.white)))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = _items[index];
                    return ListTile(
                      leading: n.actorProfileUrl != null
                          ? CircleAvatar(backgroundImage: NetworkImage(n.actorProfileUrl!))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('${n.actorUsername} ${n.type == 'like' ? 'liked' : 'commented'}', style: const TextStyle(color: Colors.white)),
                      subtitle: n.commentPreview != null ? Text(n.commentPreview!, style: const TextStyle(color: Colors.white70)) : null,
                      onTap: () {
                        // open the post (MyPostsPage) using storage key as id
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyPostsPage(userId: n.postKey.split('/').first)));
                      },
                    );
                  },
                ),
    );
  }
}
