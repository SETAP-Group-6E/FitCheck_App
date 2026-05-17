import 'dart:async';
import 'dart:math';

import 'package:fitcheck/Presentation/App/app_style/widgets/app_toast.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/feed_post_card.dart';
import 'package:fitcheck/Presentation/App/app_pages/profile/my_posts_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin<DiscoverPage> {
  @override
  bool get wantKeepAlive => true;
  // Discover page loads a randomized selection of posts and exposes
  // search/user suggestions. It keeps its state alive so users don't
  // lose the results when switching tabs.
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();

  List<_BucketPost> _allPosts = [];
  List<_BucketPost> _visiblePosts = [];
  List<_UserRow> _userSuggestions = [];
  bool _loading = true;
  bool _searchSubmitted = false;
  Timer? _debounce;
  String _resultFilter = 'posts';

  @override
  void initState() {
    super.initState();
    _loadAllPosts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Load and assemble posts from the storage bucket. Groups files by
  // timestamp/user folder and enriches each post with author data.
  Future<void> _loadAllPosts() async {
    setState(() => _loading = true);
    try {
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

          grouped.putIfAbsent(
            groupKey,
            () => _BucketPostBuilder(
              author: folderName,
              createdAt: DateTime.now(),
            ),
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

          String? caption;
          try {
            final row =
                await supabase
                    .from('post')
                    .select('caption')
                    .eq('storage_key', groupKey)
                    .maybeSingle();
            caption = (row?['caption'] as String?)?.trim();
          } catch (_) {}

          final userData = await _fetchPosterUser(group.author);

          return _BucketPost(
            id: groupKey,
            author: group.author,
            username: userData.username,
            createdAt: group.createdAt,
            imageUrls: group.images.map((i) => i.url).toList(),
            imagePaths: group.images.map((i) => i.path).toList(),
            profileImageUrl: userData.profileImageUrl,
            caption: caption,
          );
        }),
      );

      // randomize order
      posts.shuffle(Random());

      setState(() {
        _allPosts = posts;
        _visiblePosts = List.of(_allPosts);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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
      final profileImageUrlRaw = (row?['profile_pic_url'] as String?)?.trim();
      final shortenedUid = userId.length > 8 ? userId.substring(0, 8) : userId;
      final fallback = 'user_$shortenedUid';
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final profileImageUrl =
          (profileImageUrlRaw != null && profileImageUrlRaw.isNotEmpty)
              ? profileImageUrlRaw
              : supabase.storage
                  .from('Avatars')
                  .getPublicUrl('$userId/avatar.jpg?t=$cacheBuster');

      return _PosterUser(
        username:
            (username != null && username.isNotEmpty) ? username : fallback,
        profileImageUrl: profileImageUrl,
      );
    } catch (_) {
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

  Future<void> _onUserQueryChanged(String q) async {
    if (q.isEmpty) {
      setState(() => _userSuggestions = []);
      return;
    }

    try {
      final rows = await supabase
          .from('user')
          .select('user_id, username, profile_pic_url')
          .ilike('username', '%$q%')
          .limit(8);
      final list = List<Map<String, dynamic>>.from(rows as List? ?? []);
      setState(() {
        _userSuggestions =
            list.map((r) {
              final uid = r['user_id'] as String;
              final uname = (r['username'] as String?)?.trim() ?? '';
              final rawPic = (r['profile_pic_url'] as String?)?.trim();
              final cacheBuster = DateTime.now().millisecondsSinceEpoch;
              final pic =
                  (rawPic != null && rawPic.isNotEmpty)
                      ? rawPic
                      : supabase.storage
                          .from('Avatars')
                          .getPublicUrl('$uid/avatar.jpg?t=$cacheBuster');
              return _UserRow(
                userId: uid,
                username: uname,
                profileImageUrl: pic,
              );
            }).toList();
      });
    } catch (e) {
      // ignore errors silently
    }
  }

  Future<void> _performPostSearch(String q) async {
    if (q.isEmpty) {
      setState(() {
        _visiblePosts = List.of(_allPosts);
      });
      return;
    }

    try {
      final rows = await supabase
          .from('post')
          .select('storage_key, caption')
          .ilike('caption', '%$q%');
      final list = List<Map<String, dynamic>>.from(rows as List? ?? []);
      final keys = list.map((r) => r['storage_key'] as String).toSet();
      setState(() {
        _visiblePosts = _allPosts.where((p) => keys.contains(p.id)).toList();
      });
    } catch (e) {
      showAppMessage(context, 'Search failed: $e', error: true);
    }
  }

  // Open a modal dialog showing the full post. Discover is read-only,
  // so no edit/delete actions are presented here.
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
                      // No edit/delete buttons for discover view (read-only)
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Column(
                      children: [
                        // Header area matching app style
                        Container(
                          height: 140,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Row(
                            children: [
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 42,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _controller,
                                                onChanged: (v) {
                                                  // hide tabs while typing — tabs only appear after explicit submit/search
                                                  if (_searchSubmitted) {
                                                    setState(() {
                                                      _searchSubmitted = false;
                                                    });
                                                  }

                                                  if (v.isEmpty) {
                                                    setState(() {
                                                      _userSuggestions = [];
                                                    });
                                                    return;
                                                  }

                                                  // debounce user suggestion queries
                                                  if (_debounce?.isActive ??
                                                      false)
                                                    _debounce!.cancel();
                                                  _debounce = Timer(
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    () {
                                                      if (!mounted) return;
                                                      _onUserQueryChanged(v);
                                                    },
                                                  );
                                                },
                                                onSubmitted: (v) {
                                                  setState(() {
                                                    _searchSubmitted = true;
                                                  });
                                                  // cancel pending debounce and run immediately
                                                  _debounce?.cancel();
                                                  _performPostSearch(v);
                                                  _onUserQueryChanged(v);
                                                },
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Search posts or users',
                                                  hintStyle: const TextStyle(
                                                    color: Colors.white54,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.search,
                                                color: Colors.white70,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _searchSubmitted = true;
                                                });
                                                _debounce?.cancel();
                                                _performPostSearch(
                                                  _controller.text.trim(),
                                                );
                                                _onUserQueryChanged(
                                                  _controller.text.trim(),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(color: Colors.white12, height: 1),

                        // Show tabs only when a search/query produced results (users or posts)
                        Builder(
                          builder: (ctx) {
                            final query = _controller.text.trim();
                            final hasUserResults = _userSuggestions.isNotEmpty;
                            final hasPostResults =
                                query.isNotEmpty && _visiblePosts.isNotEmpty;
                            final showTabs =
                                _searchSubmitted &&
                                (hasUserResults || hasPostResults);

                            // subtle divider color that adapts to theme
                            final subtleDivider = Theme.of(
                              context,
                            ).dividerColor.withAlpha(24);

                            if (!showTabs) {
                              // default: show suggestions (live) if present, otherwise full post grid
                              if (hasUserResults) {
                                return SizedBox(
                                  height: 220,
                                  child: ListView.separated(
                                    key: const PageStorageKey(
                                      'discover-users-live',
                                    ),
                                    itemCount: _userSuggestions.length,
                                    separatorBuilder:
                                        (_, _) => Divider(
                                          height: 1,
                                          color: subtleDivider,
                                        ),
                                    itemBuilder: (context, index) {
                                      final u = _userSuggestions[index];
                                      return ListTile(
                                        leading: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: ClipOval(
                                            child:
                                                u.profileImageUrl != null
                                                    ? Image.network(
                                                      u.profileImageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            c,
                                                            e,
                                                            st,
                                                          ) => Container(
                                                            color:
                                                                Colors.white12,
                                                            child: const Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors
                                                                      .white70,
                                                            ),
                                                          ),
                                                    )
                                                    : Container(
                                                      color: Colors.white12,
                                                      child: const Icon(
                                                        Icons.person,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        title: Text(
                                          u.username,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => MyPostsPage(
                                                    userId: u.userId,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              }

                              return Expanded(
                                child:
                                    _visiblePosts.isEmpty
                                        ? const Center(
                                          child: Text(
                                            'No posts',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GridView.builder(
                                            padding: const EdgeInsets.fromLTRB(
                                              0,
                                              0,
                                              0,
                                              140,
                                            ),
                                            key: const PageStorageKey(
                                              'discover-grid',
                                            ),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 8,
                                                  mainAxisSpacing: 8,
                                                  childAspectRatio: 1,
                                                ),
                                            itemCount: _visiblePosts.length,
                                            itemBuilder: (context, index) {
                                              final p = _visiblePosts[index];
                                              final img =
                                                  p.imageUrls.isNotEmpty
                                                      ? p.imageUrls[0]
                                                      : 'Assets/profile_pic.png';
                                              return GestureDetector(
                                                onTap: () => _openPost(p),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: FadeInImage.assetNetwork(
                                                    placeholder:
                                                        'Assets/profile_pic.png',
                                                    image: img,
                                                    fit: BoxFit.cover,
                                                    imageErrorBuilder:
                                                        (
                                                          c,
                                                          e,
                                                          st,
                                                        ) => Image.asset(
                                                          'Assets/profile_pic.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                              );
                            }

                            // show filter button: Users / Posts
                            return Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Toggle button: press to switch between Users and Posts
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _resultFilter =
                                                  _resultFilter == 'users'
                                                      ? 'posts'
                                                      : 'users';
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2A2A2A),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _resultFilter == 'users'
                                                      ? Icons.person
                                                      : Icons.grid_on,
                                                  color: Colors.white70,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _resultFilter == 'users'
                                                      ? 'Users'
                                                      : 'Posts',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child:
                                        _resultFilter == 'users'
                                            ? (_userSuggestions.isEmpty
                                                ? const Center(
                                                  child: Text(
                                                    'No users',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                                : ListView.separated(
                                                  key: const PageStorageKey(
                                                    'discover-users-results',
                                                  ),
                                                  itemCount:
                                                      _userSuggestions.length,
                                                  separatorBuilder:
                                                      (_, _) => Divider(
                                                        height: 1,
                                                        color: subtleDivider,
                                                      ),
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final u =
                                                        _userSuggestions[index];
                                                    return ListTile(
                                                      leading: SizedBox(
                                                        width: 36,
                                                        height: 36,
                                                        child: ClipOval(
                                                          child:
                                                              u.profileImageUrl !=
                                                                      null
                                                                  ? Image.network(
                                                                    u.profileImageUrl!,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                    errorBuilder:
                                                                        (
                                                                          c,
                                                                          e,
                                                                          st,
                                                                        ) => Container(
                                                                          color:
                                                                              Colors.white12,
                                                                          child: const Icon(
                                                                            Icons.person,
                                                                            color:
                                                                                Colors.white70,
                                                                          ),
                                                                        ),
                                                                  )
                                                                  : Container(
                                                                    color:
                                                                        Colors
                                                                            .white12,
                                                                    child: const Icon(
                                                                      Icons
                                                                          .person,
                                                                      color:
                                                                          Colors
                                                                              .white70,
                                                                    ),
                                                                  ),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        u.username,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  _,
                                                                ) => MyPostsPage(
                                                                  userId:
                                                                      u.userId,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ))
                                            : (_visiblePosts.isEmpty
                                                ? const Center(
                                                  child: Text(
                                                    'No posts',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                                : Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: GridView.builder(
                                                    key: const PageStorageKey(
                                                      'discover-grid',
                                                    ),
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                          0,
                                                          0,
                                                          0,
                                                          140,
                                                        ),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 8,
                                                          mainAxisSpacing: 8,
                                                          childAspectRatio: 1,
                                                        ),
                                                    itemCount:
                                                        _visiblePosts.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final p =
                                                          _visiblePosts[index];
                                                      final img =
                                                          p.imageUrls.isNotEmpty
                                                              ? p.imageUrls[0]
                                                              : 'Assets/profile_pic.png';
                                                      return GestureDetector(
                                                        onTap:
                                                            () => _openPost(p),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          child: FadeInImage.assetNetwork(
                                                            placeholder:
                                                                'Assets/profile_pic.png',
                                                            image: img,
                                                            fit: BoxFit.cover,
                                                            imageErrorBuilder:
                                                                (
                                                                  c,
                                                                  e,
                                                                  st,
                                                                ) => Image.asset(
                                                                  'Assets/profile_pic.png',
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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

class _UserRow {
  _UserRow({
    required this.userId,
    required this.username,
    this.profileImageUrl,
  });
  final String userId;
  final String username;
  final String? profileImageUrl;
}
