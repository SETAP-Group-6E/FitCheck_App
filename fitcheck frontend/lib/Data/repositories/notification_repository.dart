// File: lib/Data/repositories/notification_repository.dart
// Purpose: Build notification items for the current user from likes/comments.
// Notes: Aggregates recent interactions on the current user's posts and
// computes unread status based on a `last_notif_read` timestamp stored
// in the authenticated user's metadata.

import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorUsername,
    this.actorProfileUrl,
    required this.postKey,
    this.commentPreview,
    required this.createdAt,
  });

  final String id;
  final String type; // 'like' | 'comment'
  final String actorId;
  final String actorUsername;
  final String? actorProfileUrl;
  final String postKey;
  final String? commentPreview;
  final DateTime createdAt;
}

class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> _getLastReadMillis() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;
    final meta = user.userMetadata ?? {};
    final v = meta['last_notif_read'];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> markAllRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final metadata = Map<String, dynamic>.from(user.userMetadata ?? {});
    metadata['last_notif_read'] = now;
    try {
      await _supabase.auth.updateUser(UserAttributes(data: metadata));
    } catch (_) {}
  }

  Future<List<NotificationItem>> fetchNotifications({int limit = 50}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final userId = user.id;

    // Comments on user's posts
    final commentsRows = await _supabase
        .from('comments')
        .select('comments_id, user_id, body, created_at, storage_key')
        .ilike('storage_key', '$userId/%')
        .order('created_at', ascending: false)
        .limit(limit);

    // Likes on user's posts
    final likesRows = await _supabase
        .from('post_likes')
        .select('post_like_id, user_id, created_at, storage_key')
        .ilike('storage_key', '$userId/%')
        .order('created_at', ascending: false)
        .limit(limit);

    final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(
      commentsRows as List? ?? [],
    );
    final List<Map<String, dynamic>> likes = List<Map<String, dynamic>>.from(
      likesRows as List? ?? [],
    );

    // Collect actor ids to fetch usernames
    final actorIds = <String>{};
    for (final c in comments) {
      final aid = (c['user_id'] ?? '') as String;
      if (aid.isNotEmpty && aid != userId) actorIds.add(aid);
    }
    for (final l in likes) {
      final aid = (l['user_id'] ?? '') as String;
      if (aid.isNotEmpty && aid != userId) actorIds.add(aid);
    }

    final actorMap = <String, Map<String, dynamic>>{};
    if (actorIds.isNotEmpty) {
      final futures = actorIds.map(
        (id) =>
            _supabase
                .from('user')
                .select('user_id, username, profile_pic_url')
                .eq('user_id', id)
                .maybeSingle(),
      );
      final rows = await Future.wait(futures);
      for (final r in rows) {
        if (r == null) continue;
        final row = Map<String, dynamic>.from(r as Map);
        final id = (row['user_id'] ?? '') as String;
        actorMap[id] = row;
      }
    }

    final items = <NotificationItem>[];

    for (final c in comments) {
      final actorId = (c['user_id'] ?? '') as String;
      if (actorId.isEmpty || actorId == userId)
        continue; // skip self interactions
      final createdAtStr = (c['created_at'] ?? '') as String;
      DateTime createdAt;
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAt = DateTime.now();
      }
      final actor = actorMap[actorId];
      final username =
          (actor?['username'] as String?) ??
          ('user_${actorId.substring(0, actorId.length > 8 ? 8 : actorId.length)}');
      final profile = (actor?['profile_pic_url'] as String?);
      final body = (c['body'] as String?) ?? '';
      final preview = body.length > 15 ? '${body.substring(0, 15)}…' : body;
      items.add(
        NotificationItem(
          id: 'comment_${c['comments_id'] ?? ''}',
          type: 'comment',
          actorId: actorId,
          actorUsername: username,
          actorProfileUrl: profile,
          postKey: (c['storage_key'] ?? '') as String,
          commentPreview: preview,
          createdAt: createdAt,
        ),
      );
    }

    for (final l in likes) {
      final actorId = (l['user_id'] ?? '') as String;
      if (actorId.isEmpty || actorId == userId) continue;
      final createdAtStr = (l['created_at'] ?? '') as String;
      DateTime createdAt;
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAt = DateTime.now();
      }
      final actor = actorMap[actorId];
      final username =
          (actor?['username'] as String?) ??
          ('user_${actorId.substring(0, actorId.length > 8 ? 8 : actorId.length)}');
      final profile = (actor?['profile_pic_url'] as String?);
      items.add(
        NotificationItem(
          id: 'like_${l['post_like_id'] ?? ''}',
          type: 'like',
          actorId: actorId,
          actorUsername: username,
          actorProfileUrl: profile,
          postKey: (l['storage_key'] ?? '') as String,
          commentPreview: null,
          createdAt: createdAt,
        ),
      );
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  }

  Future<int> fetchUnreadCount() async {
    final lastRead = await _getLastReadMillis();
    final items = await fetchNotifications(limit: 100);
    final unread =
        items
            .where((i) => i.createdAt.millisecondsSinceEpoch > lastRead)
            .length;
    return unread;
  }
}
