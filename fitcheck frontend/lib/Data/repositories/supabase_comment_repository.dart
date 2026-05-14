// File: lib/Data/repositories/supabase_comment_repository.dart
// Purpose: Helper for fetching and managing post comments via Supabase.
// Notes: Normalizes commenter metadata for UI consumption.

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchComments(String postKey) async {
    final rows = await _supabase
        .from('comments')
        .select('comments_id, post_id, user_id, body, created_at, storage_key')
        .eq('storage_key', postKey)
        .order('created_at', ascending: true);
    final comments = List<Map<String, dynamic>>.from(rows as List? ?? []);

    // fetch user metadata for commenters in a single query
    final userIds = comments.map((c) => (c['user_id'] ?? '') as String).where((id) => id.isNotEmpty).toSet().toList();
    if (userIds.isEmpty) return comments;

    // fetch user rows in parallel (Postgrest client may not support `in_` in this runtime)
    final futures = userIds.map((id) => _supabase.from('user').select('user_id, username, profile_pic_url').eq('user_id', id).maybeSingle());
    final usersRows = await Future.wait(futures);
    final userMap = <String, Map<String, dynamic>>{};
    for (final u in usersRows) {
      if (u == null) continue;
      final row = Map<String, dynamic>.from(u as Map);
      final id = (row['user_id'] ?? '') as String;
      userMap[id] = row;
    }

    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    for (final c in comments) {
      final uid = (c['user_id'] ?? '') as String;
      final user = userMap[uid];
      final username = (user?['username'] as String?)?.trim();
      final profilePic = (user?['profile_pic_url'] as String?)?.trim();
      final shortenedUid = uid.length > 8 ? uid.substring(0, 8) : uid;
      c['username'] = (username != null && username.isNotEmpty) ? username : 'user_$shortenedUid';
      c['profile_image_url'] = (profilePic != null && profilePic.isNotEmpty)
          ? profilePic
          : _supabase.storage.from('Avatars').getPublicUrl('$uid/avatar.jpg?t=$cacheBuster');
    }

    return comments;
  }

  Future<int> fetchCommentCount(String postKey) async {
    // Fetch comments and return the list length — avoids FetchOptions API mismatch
    final comments = await fetchComments(postKey);
    return comments.length;
  }

  Future<Map<String, dynamic>?> addComment(String postKey, String userId, String body) async {
    // `post_id` column is a UUID in the DB; use null and store the storage key
    // in `storage_key` to avoid inserting a non-UUID string into post_id.
    final res = await _supabase.from('comments').insert({
      'post_id': null,
      'storage_key': postKey,
      'user_id': userId,
      'body': body,
    }).select().maybeSingle();
    if (res == null) return null;
    final inserted = Map<String, dynamic>.from(res as Map);

    // attach user metadata for immediate UI use
    try {
      final urow = await _supabase.from('user').select('username, profile_pic_url').eq('user_id', userId).maybeSingle();
      final username = (urow?['username'] as String?)?.trim();
      final profilePic = (urow?['profile_pic_url'] as String?)?.trim();
      final shortenedUid = userId.length > 8 ? userId.substring(0, 8) : userId;
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      inserted['username'] = (username != null && username.isNotEmpty) ? username : 'user_$shortenedUid';
      inserted['profile_image_url'] = (profilePic != null && profilePic.isNotEmpty)
          ? profilePic
          : _supabase.storage.from('Avatars').getPublicUrl('$userId/avatar.jpg?t=$cacheBuster');
    } catch (_) {}

    return inserted;
  }

  /// Delete a comment by its `comments_id` ensuring the requesting user
  /// is the owner. Returns `true` when deletion succeeded, `false` on failure.
  Future<bool> deleteComment(String commentsId, String userId) async {
    try {
      // Use both `comments_id` and `user_id` to avoid deleting others' comments
      final res = await _supabase.from('comments').delete().match({
        'comments_id': commentsId,
        'user_id': userId,
      });
      // PostgREST returns a list of deleted rows (or null). Treat no exception as success.
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to delete comment $commentsId: $e');
      return false;
    }
  }
}
