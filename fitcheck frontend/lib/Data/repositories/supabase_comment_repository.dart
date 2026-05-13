import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchComments(String postKey) async {
    final rows = await _supabase
        .from('comments')
        .select('comments_id, post_id, user_id, body, created_at, storage_key')
        .eq('storage_key', postKey)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(rows as List? ?? []);
  }

  Future<int> fetchCommentCount(String postKey) async {
    // Fetch comments and return the list length — avoids FetchOptions API mismatch
    final comments = await fetchComments(postKey);
    return comments.length;
  }

  Future<Map<String, dynamic>?> addComment(String postKey, String userId, String body) async {
    final res = await _supabase.from('comments').insert({
      'post_id': postKey,
      'storage_key': postKey,
      'user_id': userId,
      'body': body,
    }).select().maybeSingle();
    return res == null ? null : Map<String, dynamic>.from(res as Map);
  }
}
