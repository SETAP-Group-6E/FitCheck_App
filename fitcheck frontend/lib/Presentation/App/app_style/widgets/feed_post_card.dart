import 'dart:async';
import 'package:flutter/gestures.dart';

import 'package:fitcheck/Data/repositories/supabase_comment_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_pages/post_comments_sheet.dart';
import 'app_toast.dart';

class FeedPostCard extends StatefulWidget {
  const FeedPostCard({
    super.key,
    required this.postId,
    required this.username,
    required this.timeLabel,
    required this.imageUrls,
    this.profileImageUrl,
    this.caption,
  });

  final String username;
  final String timeLabel;
  final List<String> imageUrls;
  final String? profileImageUrl;
  final String postId;
  final String? caption;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _likeCount = 0;
  bool _liked = false;
  bool _loadingLikes = true;
  int _commentCount = 0;
  bool _loadingComments = true;
  bool _captionExpanded = false;
  final _commentRepo = SupabaseCommentRepository();
  StreamSubscription<List<Map<String, dynamic>>>? _commentsSub;
  // comments removed: UI and backend calls disabled


  @override
  void initState() {
    super.initState();
    _loadLikes();
    _loadComments();
    // subscribe to realtime comment changes for this post
    try {
      _commentsSub = Supabase.instance.client
          .from('comments')
          .stream(primaryKey: ['comments_id'])
          .eq('storage_key', widget.postId)
          .listen((rows) {
        if (mounted) setState(() => _commentCount = List<Map<String, dynamic>>.from(rows).length);
      });
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    try {
      final count = await _commentRepo.fetchCommentCount(widget.postId);
      setState(() {
        _commentCount = count;
        _loadingComments = false;
      });
    } catch (e) {
      setState(() {
        _loadingComments = false;
      });
    }
  }

  @override
  void dispose() {
    _commentsSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLikes() async {
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase.from('post_likes').select().eq('storage_key', widget.postId);
      final list = List<Map<String, dynamic>>.from(rows as List? ?? []);
      final user = supabase.auth.currentUser;
      setState(() {
        _likeCount = list.length;
        _liked = user != null && list.any((r) => (r['user_id'] ?? r['userId'] ?? '') == user.id);
        _loadingLikes = false;
      });
    } catch (e) {
      setState(() {
        _loadingLikes = false;
      });
    }
  }

  // comment loading removed

  Future<void> _toggleLike() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      showAppMessage(context, 'Please log in to like posts.');
      Navigator.pushNamed(context, '/login');
      return;
    }

    final wasLiked = _liked;
    final originalCount = _likeCount;
    setState(() {
      _liked = !wasLiked;
      _likeCount = _liked ? originalCount + 1 : (originalCount > 0 ? originalCount - 1 : 0);
    });

    try {
      await _performDbLike(_liked, supabase, user.id);
    } catch (e, st) {
      // revert on error
      setState(() {
        _liked = wasLiked;
        _likeCount = originalCount;
      });
      final err = e.toString();
      // ignore: avoid_print
      print('Like action error: $err\n$st');
        final message = err.contains('42501') || err.toLowerCase().contains('permission denied')
          ? 'Like action failed: permission denied (check Supabase RLS for table post_likes)'
          : 'Like action failed. See console for details.';
        showAppMessage(context, message, error: true);
    }
  }

  Future<void> _performDbLike(bool like, SupabaseClient supabase, String userId) async {
    try {
      if (like) {
        await supabase.from('post_likes').insert({
          'post_id': null,
          'storage_key': widget.postId,
          'user_id': userId,
        });
      } else {
        await supabase.from('post_likes').delete().eq('storage_key', widget.postId).eq('user_id', userId);
      }
    } catch (e, st) {
      // log and rethrow so caller can show detailed error
      // ignore: avoid_print
      print('DB like error: $e\n$st');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 470),
        child: Card(
          margin: const EdgeInsets.only(bottom: 15),
          color: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(176, 217, 214, 214),
                  backgroundImage: widget.profileImageUrl != null
                      ? NetworkImage(widget.profileImageUrl!)
                      : null,
                  child: widget.profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  widget.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.timeLabel,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              if (widget.imageUrls.isNotEmpty)
                ClipRRect(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, imageIndex) {
                        return FadeInImage.assetNetwork(
                          placeholder: 'Assets/profile_pic.png',
                          image: widget.imageUrls[imageIndex],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholderFit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'Assets/profile_pic.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              if (widget.imageUrls.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.imageUrls.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 8 : 6,
                        height: isActive ? 8 : 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Like + Comment buttons + counters
                      Row(
                        children: [
                          IconButton(
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            iconSize: 22,
                            onPressed: _toggleLike,
                            icon: Icon(
                              _liked ? Icons.favorite : Icons.favorite_border,
                              color: _liked ? Colors.redAccent : Colors.white70,
                            ),
                          ),
                          if (!_loadingLikes && _likeCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '$_likeCount',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ),

                          IconButton(
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            iconSize: 22,
                            onPressed: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => PostCommentsSheet(postId: widget.postId, caption: widget.caption, timeLabel: widget.timeLabel),
                              );
                              // refresh comments count after sheet is dismissed
                              _loadComments();
                            },
                            icon: const Icon(
                              Icons.comment_outlined,
                              color: Colors.white70,
                            ),
                          ),
                          if (!_loadingComments && _commentCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '$_commentCount',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.caption != null && widget.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(builder: (context) {
                        const limit = 50;
                        final caption = widget.caption!;
                        final shouldCollapse = caption.length > limit;

                        if (!shouldCollapse) {
                          return Text(caption, style: const TextStyle(color: Colors.white));
                        }

                        // collapsed or expanded with inline tappable More/Less
                        return RichText(
                          text: TextSpan(
                            children: [
                              if (!_captionExpanded) ...[
                                TextSpan(text: caption.substring(0, limit), style: const TextStyle(color: Colors.white)),
                                const TextSpan(text: '... ', style: TextStyle(color: Colors.white)),
                                TextSpan(
                                  text: 'More',
                                  style: const TextStyle(color: Color(0xFFD99C13), fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      setState(() => _captionExpanded = true);
                                    },
                                ),
                              ] else ...[
                                TextSpan(text: caption, style: const TextStyle(color: Colors.white)),
                                TextSpan(
                                  text: ' Less',
                                  style: const TextStyle(color: Color(0xFFD99C13), fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      setState(() => _captionExpanded = false);
                                    },
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
