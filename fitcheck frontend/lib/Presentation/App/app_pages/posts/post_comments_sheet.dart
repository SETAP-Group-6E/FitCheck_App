// File: lib/Presentation/App/app_pages/posts/post_comments_sheet.dart
// Purpose: Modal bottom sheet for viewing and adding comments on a post.
// Notes: Integrates with comment repository for fetch/add operations.

// Comments sheet: slide-up, realtime comments streamer for a post (by storage_key).
// - Shows comments in realtime and provides an input for authenticated users.
// - Uses `SupabaseCommentRepository` for data operations.
import 'package:flutter/material.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/post_comment_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../../../Data/repositories/supabase_comment_repository.dart';
import '../../app_style/widgets/app_toast.dart';

class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({
    super.key,
    required this.postId,
    this.caption,
    this.timeLabel,
  });
  final String postId;
  final String? caption;
  final String? timeLabel;

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
  final bool _captionExpanded = false;

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
            try {
              final list = List<Map<String, dynamic>>.from(rows);
              // ignore: avoid_print
              print(
                'Realtime comments for ${widget.postId}: ${list.length} rows',
              );
              if (mounted) setState(() => _comments = list);
            } catch (e) {
              // ignore: avoid_print
              print('Error processing realtime comments: $e');
            }
          });
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      _comments = await _repo.fetchComments(widget.postId);
    } catch (e) {
      _comments = [];
      // ignore: avoid_print
      print('Failed to load comments for ${widget.postId}: $e');
      if (mounted)
        showAppMessage(context, 'Failed to load comments', error: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      showAppMessage(context, 'Please log in to comment.');
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
        if (mounted) showAppMessage(context, 'Comment posted');
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
      // ignore: avoid_print
      print('Failed to post comment: $e');
      if (mounted)
        showAppMessage(context, 'Failed to post comment.', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Build the UI for the comments sheet, including the header, comments list, and input area.
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
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // header area for comments sheet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                constraints: const BoxConstraints(minHeight: 64),
                child: const Center(
                  child: Text(
                    'Comments',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _comments.isEmpty
                        ? const Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: _comments.length,
                          itemBuilder: (context, i) {
                            final row = _comments[i];
                            final uid = (row['user_id'] ?? '').toString();
                            final body = (row['body'] ?? '').toString();
                            final createdAt =
                                row['created_at'] != null
                                    ? DateTime.parse(
                                      row['created_at'].toString(),
                                    )
                                    : null;
                            final timeLabel =
                                createdAt != null
                                    ? _formatTimeAgo(createdAt)
                                    : null;
                            final username = row['username']?.toString();
                            final profileImageUrl =
                                row['profile_image_url']?.toString();
                            final commentsId = row['comments_id']?.toString();
                            final supabase = Supabase.instance.client;
                            final currentUser = supabase.auth.currentUser;
                            final isOwner =
                                currentUser != null &&
                                (row['user_id'] ?? '').toString() ==
                                    currentUser.id;

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                              child: PostCommentTile(
                                username:
                                    username ??
                                    'user_${uid.substring(0, uid.length > 8 ? 8 : uid.length)}',
                                body: body,
                                timeLabel: timeLabel,
                                profileImageUrl: profileImageUrl,
                                isOwn: isOwner,
                                onDelete:
                                    isOwner
                                        ? () async {
                                          // optimistic remove
                                          final index = i;
                                          final removed = _comments[index];
                                          setState(
                                            () => _comments.removeAt(index),
                                          );
                                          final success = await _repo
                                              .deleteComment(
                                                commentsId ?? '',
                                                currentUser.id,
                                              );
                                          if (!success) {
                                            // rollback
                                            if (mounted) {
                                              setState(
                                                () => _comments.insert(
                                                  index,
                                                  removed,
                                                ),
                                              );
                                              showAppMessage(
                                                context,
                                                'Failed to delete comment.',
                                                error: true,
                                              );
                                            }
                                          } else {
                                            if (mounted)
                                              showAppMessage(
                                                context,
                                                'Comment deleted',
                                              );
                                          }
                                        }
                                        : null,
                              ),
                            );
                          },
                        ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                child: Builder(
                  builder: (context) {
                    final supabase = Supabase.instance.client;
                    final user = supabase.auth.currentUser;
                    if (user == null) {
                      return Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Sign in to post comments',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () => Navigator.pushNamed(context, '/login'),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(color: Color(0xFFD99C13)),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFD99C13),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder:
                              (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                          child:
                              _submitting
                                  ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 42,
                                    height: 42,
                                    child: Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                  : ElevatedButton(
                                    key: const ValueKey('send'),
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD99C13),
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(48, 42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.keyboard_return,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ],
                    );
                  },
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
