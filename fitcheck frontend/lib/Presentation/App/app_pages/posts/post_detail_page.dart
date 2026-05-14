// File: lib/Presentation/App/app_pages/posts/post_detail_page.dart
// Purpose: Detailed view of a single post, includes comments and interactions.
// Notes: Shows full image, caption, likes, and comment sheet.

// PostDetailPage: shows a single post's caption and full comments list.
// - Allows authenticated users to add comments.
// - Loads caption from `post` table and comments via repository.
import 'package:fitcheck/Presentation/App/app_style/widgets/post_comment_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_style/widgets/app_toast.dart';
import '../../../../Data/repositories/supabase_comment_repository.dart';

// PostDetailPage
// ----------------
// Shows a single post's caption (if present) and its comments.
// Users can add a new comment using the input at the bottom.
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // Repository used to fetch/add comments
  final _repo = SupabaseCommentRepository();

  // Controller for the comment input
  final _controller = TextEditingController();

  // In-memory comments list and loading flag
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  // Cached caption for the post (may be null)
  String? _caption;

  @override
  void initState() {
    super.initState();
    // Load caption and comments on init
    _loadCaption();
    _loadComments();
  }

  // Load the post caption from the `post` table (if present).
  Future<void> _loadCaption() async {
    try {
      final supabase = Supabase.instance.client;
      final row = await supabase.from('post').select('caption').eq('storage_key', widget.postId).maybeSingle();
      setState(() {
        _caption = (row?['caption'] as String?)?.trim();
      });
    } catch (e) {
      debugPrint('Error loading caption: $e');
      setState(() => _caption = null);
    }
  }

  // Load comments using the comment repository
  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      _comments = await _repo.fetchComments(widget.postId);
    } catch (e) {
      debugPrint('Error loading comments: $e');
      _comments = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  // Submit a new comment and reload comments on success
  Future<void> _submit() async {
    // Validate auth and post a new comment using the comment repository.
    // On success, clear the input and refresh the comment list.
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      showAppMessage(context, 'Please log in to comment.');
      Navigator.pushNamed(context, '/login');
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await _repo.addComment(widget.postId, user.id, text);
      _controller.clear();
      await _loadComments();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      showAppMessage(context, 'Failed to post comment.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          // Caption appears above comments if available
          if (_caption != null && _caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          // Comments list (or loading spinner)
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, i) {
                      final row = _comments[i];
                      final uid = (row['user_id'] ?? '') as String;
                      final body = (row['body'] ?? '') as String;
                      final createdAt = row['created_at'] != null ? DateTime.parse(row['created_at']) : null;
                      final timeLabel = createdAt != null ? _formatTimeAgo(createdAt) : null;
                      final username = 'user_${uid.substring(0, uid.length > 8 ? 8 : uid.length)}';
                      return PostCommentTile(username: username, body: body, timeLabel: timeLabel);
                    },
                  ),
          ),

          // New comment input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Write a comment...', hintStyle: TextStyle(color: Colors.white54)),
                  ),
                ),
                IconButton(onPressed: _submit, icon: const Icon(Icons.send, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small helper to format a DateTime as a relative time label
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}';
  }
}
