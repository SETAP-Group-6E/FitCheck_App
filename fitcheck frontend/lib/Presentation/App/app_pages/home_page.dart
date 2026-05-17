// File: lib/Presentation/App/app_pages/home_page.dart
// Purpose: Main landing/home screen for the app feed.
// Notes: Hosts primary feed and navigation entry points.

import 'dart:async';

import 'package:fitcheck/Presentation/App/app_pages/posts/social.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/feed_post_card.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/floating_nav_bar.dart';
import 'package:flutter/foundation.dart';
// Feed / Home page: loads posts from storage and displays the feed cards.
// - Handles navigation to post creation and post detail views.
import 'package:flutter/material.dart';
import '../app_style/widgets/app_toast.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitcheck/Data/repositories/notification_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // HomePage state holds feed data, notification counts and UI helpers.
  // Responsibilities:
  // - Load posts from Supabase storage buckets and map them to feed cards
  // - Poll for unread notifications and expose a badge in the header
  // - Provide navigation to post drafting and notifications
  final supabase = Supabase.instance.client;
  final NotificationRepository _notifRepo = NotificationRepository();
  int _unreadCount = 0;
  Timer? _notifPollTimer;
  StreamSubscription<AuthState>? _authSubscription;
  Future<List<_BucketPost>> _feedFuture = Future.value(const <_BucketPost>[]);
  bool _showNoMorePostsPrompt = false;
  bool _isScrollingDown = false;
  Timer? _noMorePostsTimer;

  void _refreshFeed() {
    _feedFuture = _fetchBucketPosts().timeout(
      const Duration(seconds: 12),
      onTimeout: () => <_BucketPost>[],
    );
  }

  @override
  void initState() {
    super.initState();
    // Kick off initial feed load and notification polling
    _refreshFeed();
    _fetchUnread();
    _notifPollTimer = Timer.periodic(const Duration(seconds: 20), (_) => _fetchUnread());
    // Listen for auth state changes so we refresh unread count immediately
    _authSubscription = supabase.auth.onAuthStateChange.listen((_) {
      _fetchUnread();
    });
  }

  @override
  void dispose() {
    // Cancel background timers when leaving the home page
    _noMorePostsTimer?.cancel();
    _notifPollTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnread() async {
    try {
      final user = supabase.auth.currentUser;
      debugPrint('Fetching unread notifications; user=${user?.id}');
      final count = await _notifRepo.fetchUnreadCount();
      if (!mounted) return;
      debugPrint('Unread count: $count');
      setState(() {
        _unreadCount = count;
      });
    } catch (_) {}
  }

  void _triggerNoMorePostsPrompt() {
    _noMorePostsTimer?.cancel();
    if (!_showNoMorePostsPrompt) {
      setState(() {
        _showNoMorePostsPrompt = true;
      });
    }

    _noMorePostsTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showNoMorePostsPrompt = false;
      });
    });
  }

  void _hideNoMorePostsPrompt() {
    _noMorePostsTimer?.cancel();
    if (_showNoMorePostsPrompt) {
      setState(() {
        _showNoMorePostsPrompt = false;
      });
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}';
    }
  }

  // Reads all user post folders from Supabase storage and builds a list
  // of posts sorted by creation time. This is a relatively expensive
  // operation and is called on refresh or when returning from posting.
  Future<List<_BucketPost>> _fetchBucketPosts() async {
    final bucket = supabase.storage.from('User Posts');
    final rootEntries = await bucket.list(
      searchOptions: const SearchOptions(limit: 1000),
    );

    final grouped = <String, _BucketPostBuilder>{};
    final tsRegex = RegExp(r'^(\d+)_\d+\.[^\.]+$');
    final indexRegex = RegExp(r'^\d+_(\d+)\.[^\.]+$');

    for (final entry in rootEntries) {
      final folderName = entry.name;
      if (folderName.contains('.')) {
        continue;
      }

      final files = await bucket.list(
        path: folderName,
        searchOptions: const SearchOptions(limit: 1000),
      );

      for (final file in files) {
        final fileName = file.name;
        if (!fileName.contains('.')) {
          continue;
        }

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
                : '$folderName/$timestamp';
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
          _PostImage(order: imageOrder, url: bucket.getPublicUrl(path)),
        );
      }
    }

    final posts = await Future.wait(
      grouped.entries.map((entry) async {
        final groupKey = entry.key;
        final group = entry.value;
        group.images.sort((a, b) => a.order.compareTo(b.order));
        final userData = await _fetchPosterUser(group.author);

        // Try to fetch post row (contains caption) from `post` table
        String? caption;
        try {
          final row = await supabase.from('post').select('caption').eq('storage_key', groupKey).maybeSingle();
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
          profileImageUrl: userData.profileImageUrl,
          caption: caption,
        );
      }),
    );

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
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
      debugPrint('Error fetching user row for $userId: $e');
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

  @override
  Widget build(BuildContext context) {
    // Main scaffold containing the feed list, header with bell/+ buttons,
    // and a small no-more-posts prompt overlay when the user scrolls past
    // the end of the feed.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Feed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      // Notification bell 
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final res = await Navigator.pushNamed(context, '/notifications');
                              if (res == true) {
                                // Notifications were marked read by the page; refresh
                                // the unread count immediately instead of waiting
                                // for the next poll.
                                _fetchUnread();
                              }
                            },
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          if (_unreadCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                                child: Text(_unreadCount > 99 ? '99+' : '$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final user = supabase.auth.currentUser;
                          if (user == null) {
                            showAppMessage(context, 'Please log in to create a post.');
                            Navigator.pushNamed(context, '/login');
                            return;
                          }

                          final posted = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              settings: const RouteSettings(name: '/post_drafting'),
                              builder: (_) => const PostDraftingPage(),
                            ),
                          );

                          if (posted == true && mounted) {
                            setState(() {
                              _refreshFeed();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<_BucketPost>>(
                    future: _feedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load feed: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final posts = snapshot.data ?? const <_BucketPost>[];
                      if (posts.isEmpty) {
                        return const Center(
                          child: Text(
                            'No posts yet.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              final pixels = notification.metrics.pixels;
                              final max = notification.metrics.maxScrollExtent;
                              final atBottom = pixels >= max - 1;

                              if (notification is OverscrollNotification) {
                                if (atBottom &&
                                    _isScrollingDown &&
                                    notification.overscroll > 0) {
                                  _triggerNoMorePostsPrompt();
                                }
                              } else if (notification
                                  is ScrollUpdateNotification) {
                                final delta = notification.scrollDelta ?? 0;
                                final scrollingDown = delta > 0;
                                final scrollingUp = delta < 0;

                                if (atBottom && scrollingDown) {
                                  _triggerNoMorePostsPrompt();
                                } else if (scrollingUp || !atBottom) {
                                  _hideNoMorePostsPrompt();
                                }
                              } else if (notification
                                  is UserScrollNotification) {
                                _isScrollingDown =
                                    notification.direction ==
                                    ScrollDirection.reverse;

                                if (notification.direction ==
                                    ScrollDirection.forward) {
                                  _hideNoMorePostsPrompt();
                                } else if (!atBottom) {
                                  _hideNoMorePostsPrompt();
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                6,
                                12,
                                100,
                              ),
                              itemCount:
                                  kIsWeb ? posts.length + 1 : posts.length,
                              itemBuilder: (context, index) {
                                if (kIsWeb && index == posts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    child: Center(
                                      child: Text(
                                        'No more posts',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final post = posts[index];
                                return FeedPostCard(
                                  postId: post.id,
                                  authorId: post.author,
                                  username: post.username,
                                  timeLabel: _formatTimeAgo(post.createdAt),
                                  imageUrls: post.imageUrls,
                                  profileImageUrl: post.profileImageUrl,
                                  caption: post.caption,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!kIsWeb)
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _showNoMorePostsPrompt ? 1 : 0,
                    child: const Text(
                      'No more posts',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          const FloatingNavbar(),
        ],
      ),
    );
  }
}

class _BucketPost {
  final String id;
  final String author;
  final String username;
  final DateTime createdAt;
  final List<String> imageUrls;
  final String? profileImageUrl;
  final String? caption;

  const _BucketPost({
    required this.id,
    required this.author,
    required this.username,
    required this.createdAt,
    required this.imageUrls,
    this.profileImageUrl,
    this.caption,
  });
}

class _BucketPostBuilder {
  final String author;
  final DateTime createdAt;
  final List<_PostImage> images = [];

  _BucketPostBuilder({required this.author, required this.createdAt});
}

class _PosterUser {
  final String username;
  final String profileImageUrl;

  const _PosterUser({required this.username, required this.profileImageUrl});
}

class _PostImage {
  final int order;
  final String url;

  const _PostImage({required this.order, required this.url});
}
