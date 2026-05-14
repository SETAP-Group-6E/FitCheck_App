// File: lib/Presentation/App/app_pages/notifications_page.dart
// Purpose: Simple notifications list showing likes and comment previews.
// Notes: Allows marking all as read which updates user metadata.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitcheck/Data/repositories/notification_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/profile/my_posts_page.dart';
import 'package:fitcheck/Presentation/App/app_state.dart' as app_state;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final repo = NotificationRepository();
  bool _loading = false;
  List<NotificationItem> _items = [];

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    // hide global navbar while notifications are visible
    app_state.navbarVisible.value = false;
    if (_isAuthenticated) {
      _load();
    }
  }

  @override
  void dispose() {
    // restore navbar when leaving notifications
    app_state.navbarVisible.value = true;
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await repo.fetchNotifications(limit: 200).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await repo.markAllRead();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please sign in to view your notifications', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_items.isEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 56, color: theme.colorScheme.onBackground.withOpacity(0.6)),
            const SizedBox(height: 8),
            Text("You're all caught up", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('No new notifications', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7))),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _items.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
          itemBuilder: (context, index) {
            final n = _items[index];
            return ListTile(
              leading: n.actorProfileUrl != null
                  ? CircleAvatar(backgroundImage: NetworkImage(n.actorProfileUrl!))
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text('${n.actorUsername} ${n.type == 'like' ? 'liked' : 'commented'}', style: theme.textTheme.bodyLarge),
              subtitle: n.commentPreview != null ? Text(n.commentPreview!, style: theme.textTheme.bodyMedium) : null,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyPostsPage(userId: n.postKey.split('/').first)));
              },
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _markAllRead,
            child: Text('Mark all read', style: theme.textTheme.labelLarge?.copyWith(color: _items.isEmpty ? theme.disabledColor : theme.colorScheme.onPrimary)),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: content,
      ),
    );
  }
}
