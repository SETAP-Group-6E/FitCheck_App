import 'package:flutter/material.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/post_comment_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../../Data/repositories/supabase_comment_repository.dart';

class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({super.key, required this.postId});
  final String postId;

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final _repo = SupabaseCommentRepository();
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _submitting = false;
  StreamSubscription<List<Map<String, dynamic>>>? _commentsSub;
  ScrollController? _sheetScrollController;

  @override
  void initState() {
    super.initState();
    _loadComments();
    // subscribe to realtime updates for comments on this storage_key
    try {
      _commentsSub = Supabase.instance.client
          .from('comments')
          .stream(primaryKey: ['comments_id'])
          .eq('storage_key', widget.postId)
          .listen((rows) {
        if (mounted) setState(() => _comments = List<Map<String, dynamic>>.from(rows));
      });
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      _comments = await _repo.fetchComments(widget.postId);
    } catch (e) {
      _comments = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to comment.')));
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final inserted = await _repo.addComment(widget.postId, user.id, text);
      _controller.clear();
      if (inserted != null) {
        if (mounted) setState(() => _comments.add(inserted));
        // scroll to bottom to show the newly added comment
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _sheetScrollController?.animateTo(
              _sheetScrollController!.position.maxScrollExtent + 80,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } catch (_) {}
        });
      } else {
        // fallback optimistic append if insert returned nothing
        final newComment = {
          'comments_id': null,
          'post_id': widget.postId,
          'storage_key': widget.postId,
          'user_id': user.id,
          'body': text,
          'created_at': DateTime.now().toIso8601String(),
        };
        if (mounted) setState(() => _comments.add(newComment));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post comment.')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        // keep reference so we can auto-scroll after posting
        _sheetScrollController = scrollController;
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Container(
                height: 36,
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: scrollController,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Color(0xFF1E1E1E),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: _submitting
                          ? const SizedBox(key: ValueKey('loading'), width: 36, height: 36, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
                          : IconButton(
                              key: const ValueKey('send'),
                              onPressed: _submit,
                              icon: const Icon(Icons.send, color: Colors.white70),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _commentsSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

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
