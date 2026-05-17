// File: lib/Presentation/App/app_pages/profile/my_posts_page.dart
// Purpose: Displays a user's posts in a grid with edit/delete actions.
// Notes: Supports viewing other users' posts and the current user's posts.

import 'dart:async';

import 'package:fitcheck/Presentation/App/app_style/widgets/app_toast.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/feed_post_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPostsPage extends StatefulWidget {
  final String? userId;
  const MyPostsPage({super.key, this.userId});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage>
    with AutomaticKeepAliveClientMixin<MyPostsPage> {
  @override
  bool get wantKeepAlive => true;
  // MyPostsPage loads posts for a particular user (or the signed-in user)
  // and supports editing or deleting posts when appropriate. It paginates
  // results locally and preserves scroll position via a PageStorageKey.
  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  List<_BucketPost> _allPosts = [];
  List<_BucketPost> _visiblePosts = [];
  bool _loading = true;
  final int _perPage = 30;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels > pos.maxScrollExtent - 300 &&
        _visiblePosts.length < _allPosts.length) {
      _appendMore();
    }
  }

  void _appendMore() {
    // Append the next page of posts into the visible list.
    final nextEnd = (_visiblePosts.length + _perPage).clamp(
      0,
      _allPosts.length,
    );
    setState(() {
      _visiblePosts = _allPosts.sublist(0, nextEnd);
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
    });

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final targetUserId = widget.userId ?? currentUserId;

      if (targetUserId == null) {
        // No target specified and user not signed in
        showAppMessage(context, 'Please sign in to view your posts.');
        setState(() {
          _allPosts = [];
          _visiblePosts = [];
          _loading = false;
        });
        return;
      }

      final bucket = supabase.storage.from('User Posts');
      final rootEntries = await bucket.list(
        searchOptions: const SearchOptions(limit: 1000),
      );

      final grouped = <String, _BucketPostBuilder>{};
      final tsRegex = RegExp(r'^(\d+)_\d+\.[^\.]+$');
      final indexRegex = RegExp(r'^\d+_(\d+)\.[^\.]+$');

      for (final entry in rootEntries) {
        final folderName = entry.name;
        if (folderName.contains('.')) continue;

        // only include folders that belong to the target user
        if (folderName != targetUserId) continue;

        final files = await bucket.list(
          path: folderName,
          searchOptions: const SearchOptions(limit: 1000),
        );

        for (final file in files) {
          final fileName = file.name;
          if (!fileName.contains('.')) continue;

          final tsMatch = tsRegex.firstMatch(fileName);
          final indexMatch = indexRegex.firstMatch(fileName);
          final timestamp =
              tsMatch == null ? 0 : int.tryParse(tsMatch.group(1) ?? '0') ?? 0;
          final imageOrder =
              indexMatch == null
                  ? 0
                  : int.tryParse(indexMatch.group(1) ?? '0') ?? 0;
          final groupKey =
              tsMatch == null
                  ? '$folderName/$fileName'
                  : '$folderName/${tsMatch.group(1)}';
          final path = '$folderName/$fileName';
          final createdAt =
              timestamp > 0
                  ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                  : DateTime.now();

          grouped.putIfAbsent(
            groupKey,
            () => _BucketPostBuilder(author: folderName, createdAt: createdAt),
          );

          grouped[groupKey]!.images.add(
            _PostImage(
              order: imageOrder,
              path: path,
              url: bucket.getPublicUrl(path),
            ),
          );
        }
      }

      final posts = await Future.wait(
        grouped.entries.map((entry) async {
          final groupKey = entry.key;
          final group = entry.value;
          group.images.sort((a, b) => a.order.compareTo(b.order));
          final userData = await _fetchPosterUser(group.author);

          String? caption;
          try {
            final row =
                await supabase
                    .from('post')
                    .select('caption')
                    .eq('storage_key', groupKey)
                    .maybeSingle();
            caption = (row?['caption'] as String?)?.trim();
          } catch (_) {
            caption = null;
          }

          return _BucketPost(
            id: groupKey,
            author: group.author,
            username: userData.username,
            createdAt: group.createdAt,
            imageUrls: group.images.map((img) => img.url).toList(),
            imagePaths: group.images.map((img) => img.path).toList(),
            profileImageUrl: userData.profileImageUrl,
            caption: caption,
          );
        }),
      );

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allPosts = posts;
        _visiblePosts = _allPosts.sublist(
          0,
          _perPage.clamp(0, _allPosts.length),
        );
        _loading = false;
      });

      // after posts are set, compute header user details and likes
      try {
        final userData = await _fetchPosterUser(targetUserId);
        int likes = 0;
        if (_allPosts.isNotEmpty) {
          final futures = _allPosts.map((p) async {
            try {
              final rows = await supabase
                  .from('post_likes')
                  .select()
                  .eq('storage_key', p.id);
              final list = List<Map<String, dynamic>>.from(rows as List? ?? []);
              return list.length;
            } catch (_) {
              return 0;
            }
          });
          final results = await Future.wait(futures);
          likes = results.fold(0, (a, b) => a + b);
        }

        if (mounted) {
          setState(() {
            _currentUsername = userData.username;
            _currentAvatarUrl = userData.profileImageUrl;
            _likesCount = likes;
          });
        }
      } catch (_) {}
    } catch (e) {
      setState(() {
        _allPosts = [];
        _visiblePosts = [];
        _loading = false;
      });
      showAppMessage(context, 'Failed to load posts: $e', error: true);
    }
  }

  Future<_PosterUser> _fetchPosterUser(String userId) async {
    try {
      final row =
          await supabase
              .from('user')
              .select('username, profile_pic_url')
              .eq('user_id', userId)
              .maybeSingle();
      final username = (row?['username'] as String?)?.trim();
      final profileImageUrl = (row?['profile_pic_url'] as String?)?.trim();
      final shortenedUid = userId.length > 8 ? userId.substring(0, 8) : userId;
      final fallbackUsername = 'user_$shortenedUid';
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;

      return _PosterUser(
        username:
            (username != null && username.isNotEmpty)
                ? username
                : fallbackUsername,
        profileImageUrl:
            profileImageUrl != null && profileImageUrl.isNotEmpty
                ? profileImageUrl
                : supabase.storage
                    .from('Avatars')
                    .getPublicUrl('$userId/avatar.jpg?t=$cacheBuster'),
      );
    } catch (e) {
      final shortenedUid = userId.length > 8 ? userId.substring(0, 8) : userId;
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      return _PosterUser(
        username: 'user_$shortenedUid',
        profileImageUrl: supabase.storage
            .from('Avatars')
            .getPublicUrl('$userId/avatar.jpg?t=$cacheBuster'),
      );
    }
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

  Future<void> _deletePost(_BucketPost post) async {
    // Confirm and remove a post's storage objects and DB rows.
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            title: const Text(
              'Delete post',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Permanently delete this post?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final bucket = supabase.storage.from('User Posts');
      // remove storage objects
      if (post.imagePaths.isNotEmpty) {
        await bucket.remove(post.imagePaths);
      }

      // delete related DB rows
      await supabase.from('post_likes').delete().eq('storage_key', post.id);
      await supabase.from('comments').delete().eq('storage_key', post.id);
      await supabase.from('post').delete().eq('storage_key', post.id);

      showAppMessage(context, 'Post deleted');
      await _loadPosts();
    } catch (e) {
      showAppMessage(context, 'Failed to delete post: $e', error: true);
    }
  }

  Future<void> _editCaption(_BucketPost post) async {
    final controller = TextEditingController(text: post.caption ?? '');
    final changed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            title: const Text(
              'Edit caption',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFFD99C13),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (changed != true) return;

    try {
      await supabase
          .from('post')
          .update({'caption': controller.text.trim()})
          .eq('storage_key', post.id);
      showAppMessage(context, 'Caption updated');
      await _loadPosts();
    } catch (e) {
      showAppMessage(context, 'Failed to update caption: $e', error: true);
    }
  }

  void _openPost(_BucketPost post) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Stack(
                    children: [
                      FeedPostCard(
                        postId: post.id,
                        authorId: post.author,
                        username: post.username,
                        timeLabel: _formatTimeAgo(post.createdAt),
                        imageUrls: post.imageUrls,
                        profileImageUrl: post.profileImageUrl,
                        caption: post.caption,
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          color: const Color(0xFF121212),
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                            size: 20,
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _editCaption(post);
                            } else if (value == 'delete') {
                              final confirmed =
                                  await showDialog<bool>(
                                    context: ctx,
                                    builder:
                                        (dCtx) => AlertDialog(
                                          backgroundColor: const Color(
                                            0xFF121212,
                                          ),
                                          title: Text(
                                            'Delete post',
                                            style: Theme.of(dCtx)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Permanently delete this post?',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 420,
                                                    ),
                                                child: Text(
                                                  'This will remove the post and its associated images.',
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    dCtx,
                                                  ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    dCtx,
                                                  ).pop(true),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Color(0xFFD99C13),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  ) ??
                                  false;

                              if (confirmed) {
                                await _deletePost(post);
                                Navigator.of(ctx).pop();
                              }
                            }
                          },
                          itemBuilder:
                              (menuCtx) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit caption',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String? _currentUsername;
  String? _currentAvatarUrl;
  int _likesCount = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Profile header reserved area (increased container height)
                    Container(
                      height: 140,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          // Always show back button per request
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () => Navigator.maybePop(context),
                          ),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child:
                                  _currentAvatarUrl == null
                                      ? Image.asset(
                                        'Assets/profile_pic.png',
                                        fit: BoxFit.cover,
                                      )
                                      : Image.network(
                                        _currentAvatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, _, _) => Image.asset(
                                              'Assets/profile_pic.png',
                                              fit: BoxFit.cover,
                                            ),
                                      ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (ctx) {
                                    final signedInId =
                                        Supabase
                                            .instance
                                            .client
                                            .auth
                                            .currentUser
                                            ?.id;
                                    final isOwn =
                                        widget.userId == null ||
                                        widget.userId == signedInId;
                                    final title =
                                        isOwn
                                            ? 'My Posts'
                                            : "${_currentUsername ?? 'User'}'s posts";
                                    return Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_allPosts.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Posts',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 18),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$_likesCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Likes',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed:
                                () => Navigator.pushNamed(context, '/settings'),
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white12, height: 1),

                    // Grid of posts
                    Expanded(
                      child:
                          _visiblePosts.isEmpty
                              ? const Center(
                                child: Text(
                                  'No posts yet',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  key: PageStorageKey(
                                    'my-posts-grid-${widget.userId ?? 'me'}',
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    140,
                                  ),
                                  controller: _scrollController,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 1,
                                      ),
                                  itemCount: _visiblePosts.length,
                                  itemBuilder: (context, index) {
                                    final post = _visiblePosts[index];
                                    final image =
                                        post.imageUrls.isNotEmpty
                                            ? post.imageUrls[0]
                                            : 'Assets/profile_pic.png';
                                    return GestureDetector(
                                      onTap: () => _openPost(post),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'Assets/profile_pic.png',
                                          image: image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          imageErrorBuilder:
                                              (c, e, st) => Image.asset(
                                                'Assets/profile_pic.png',
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
              ),

          // Floating navigation bar is provided by the app shell.
        ],
      ),
    );
  }
}

class _BucketPost {
  _BucketPost({
    required this.id,
    required this.author,
    required this.username,
    required this.createdAt,
    required this.imageUrls,
    required this.imagePaths,
    this.profileImageUrl,
    this.caption,
  });

  final String id;
  final String author;
  final String username;
  final DateTime createdAt;
  final List<String> imageUrls;
  final List<String> imagePaths;
  final String? profileImageUrl;
  final String? caption;
}

class _BucketPostBuilder {
  _BucketPostBuilder({required this.author, required this.createdAt});
  final String author;
  final DateTime createdAt;
  final List<_PostImage> images = [];
}

class _PostImage {
  _PostImage({required this.order, required this.path, required this.url});
  final int order;
  final String path;
  final String url;
}

class _PosterUser {
  _PosterUser({required this.username, required this.profileImageUrl});
  final String username;
  final String profileImageUrl;
}
