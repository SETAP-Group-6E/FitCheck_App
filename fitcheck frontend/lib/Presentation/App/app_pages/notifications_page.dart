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

  bool get _isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

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
      final items = await repo
          .fetchNotifications(limit: 200)
          .timeout(const Duration(seconds: 8));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use white shades for text/icons regardless of theme for high contrast
    final textColor = Colors.white;

    if (!_isAuthenticated) {
      // Unauthenticated: show matching header and prompt to sign in.
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                height: 120,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: theme.scaffoldBackgroundColor,
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor.withOpacity(0.92),
                        size: 20,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Notifications',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Please sign in to view your notifications',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/login'),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            Icon(
              Icons.notifications_off,
              size: 56,
              color: textColor.withOpacity(0.88),
            ),
            const SizedBox(height: 8),
            Text(
              "You're all caught up",
              style: theme.textTheme.titleMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              'No new notifications',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacity(0.88),
              ),
            ),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _items.length,
          separatorBuilder:
              (_, _) => Divider(height: 1, color: theme.dividerColor),
          itemBuilder: (context, index) {
            final n = _items[index];
            return ListTile(
              leading:
                  n.actorProfileUrl != null
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(n.actorProfileUrl!),
                      )
                      : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                '${n.actorUsername} ${n.type == 'like' ? 'liked' : 'commented'}',
                style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
              ),
              subtitle:
                  n.commentPreview != null
                      ? Text(
                        n.commentPreview!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.85),
                        ),
                      )
                      : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => MyPostsPage(userId: n.postKey.split('/').first),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    // Use WillPopScope so system back (Android) also triggers mark-as-read.
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header matching app style (back button + centered title)
            Container(
              height: 120,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: theme.scaffoldBackgroundColor,
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: textColor.withOpacity(0.92),
                      size: 20,
                    ),
                    onPressed: () {
                      // When the user navigates back, assume notifications are
                      // read and mark them on the server (fire-and-forget).
                      if (_isAuthenticated) {
                        repo.markAllRead();
                      }
                      Navigator.maybePop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Content area wrapped in WillPopScope so system back marks read.
            Expanded(
              child: WillPopScope(
                onWillPop: () async {
                  if (_isAuthenticated) {
                    // Fire-and-forget; we don't need to await completion.
                    repo.markAllRead();
                  }
                  return true;
                },
                child: Container(
                  width: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
