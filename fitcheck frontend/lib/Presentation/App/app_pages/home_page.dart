import 'package:fitcheck/Presentation/App/app_pages/social.dart';
import 'package:fitcheck/Presentation/App/app_style/floating_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  Future<List<_BucketPost>> _feedFuture = Future.value(const <_BucketPost>[]);

  void _refreshFeed() {
    _feedFuture = _fetchBucketPosts().timeout(
      const Duration(seconds: 12),
      onTimeout: () => <_BucketPost>[],
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshFeed();
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
        final timestamp = tsMatch == null
            ? 0
            : int.tryParse(tsMatch.group(1) ?? '0') ?? 0;
        final imageOrder = indexMatch == null
            ? 0
            : int.tryParse(indexMatch.group(1) ?? '0') ?? 0;
        final groupKey = tsMatch == null
            ? '$folderName/$fileName'
            : '$folderName/$timestamp';
        final path = '$folderName/$fileName';
        final createdAt = timestamp > 0
            ? DateTime.fromMillisecondsSinceEpoch(timestamp)
            : DateTime.now();

        grouped.putIfAbsent(
          groupKey,
          () => _BucketPostBuilder(author: folderName, createdAt: createdAt),
        );
        grouped[groupKey]!.images.add(
          _PostImage(
            order: imageOrder,
            url: bucket.getPublicUrl(path),
          ),
        );
      }
    }

    final posts = grouped.values
        .map((group) async {
          group.images.sort((a, b) => a.order.compareTo(b.order));
          
          String? avatarUrl;
          try {
            final avatarBucket = supabase.storage.from('Avatars');
            avatarUrl = avatarBucket.getPublicUrl('${group.author}/avatar.jpg');
          } catch (e) {
            debugPrint('Error getting avatar URL for ${group.author}: $e');
          }
          debugPrint('Generated avatar URL for ${group.author}: $avatarUrl');
          
          // Fetch username from users table
          String? username;
          try {
            final userResponse = await supabase
                .from('user')
                .select('username')
                .eq('id', group.author)
                .single();
            username = userResponse['username'] as String?;
          } catch (e) {
            debugPrint('Error fetching username for ${group.author}: $e');
          }
          
          return _BucketPost(
            author: group.author,
            username: username ?? group.author,
            createdAt: group.createdAt,
            imageUrls: group.images.map((img) => img.url).toList(),
            profileImageUrl: avatarUrl,
          );
        })
        .toList();

    final resolvedPosts = await Future.wait(posts);
    resolvedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return resolvedPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                      IconButton(
                        onPressed: () async {
                          final user = supabase.auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please log in to create a post.'),
                              ),
                            );
                            Navigator.pushNamed(context, '/login');
                            return;
                          }

                          final posted = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
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

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 110),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final username = post.username;
                          final imageUrls = post.imageUrls;
                          final createdAt = post.createdAt;
                          debugPrint('Post $index: username=$username, profileImageUrl=${post.profileImageUrl}');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: const Color(0xFF121212),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color.fromARGB(176, 217, 214, 214),
                                    backgroundImage: post.profileImageUrl != null
                                        ? NetworkImage(post.profileImageUrl!)
                                        : null,
                                    child: post.profileImageUrl == null
                                        ? const Icon(Icons.person, color: Colors.white)
                                        : null,
                                  ),
                                  title: Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _formatTimeAgo(createdAt),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                                if (imageUrls.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      height: 260,
                                      child: PageView.builder(
                                        itemCount: imageUrls.length,
                                        itemBuilder: (context, imageIndex) {
                                          return FadeInImage.assetNetwork(
                                            placeholder: 'Assets/profile_pic.png',
                                            image: imageUrls[imageIndex],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholderFit: BoxFit.cover,
                                            imageErrorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
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
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const FloatingNavbar(),
        ],
      ),
    );
  }
}

class _BucketPost {
  final String author;
  final String username;
  final DateTime createdAt;
  final List<String> imageUrls;
  final String? profileImageUrl;

  const _BucketPost({
    required this.author,
    required this.username,
    required this.createdAt,
    required this.imageUrls,
    this.profileImageUrl,
  });
}

class _BucketPostBuilder {
  final String author;
  final DateTime createdAt;
  final List<_PostImage> images = [];
  String? profileImageUrl;

  _BucketPostBuilder({required this.author, required this.createdAt});
}

class _PostImage {
  final int order;
  final String url;

  const _PostImage({required this.order, required this.url});
}
