import 'package:flutter/material.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.username,
    required this.timeLabel,
    required this.imageUrls,
    this.profileImageUrl,
  });

  final String username;
  final String timeLabel;
  final List<String> imageUrls;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 445),
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
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
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
                  timeLabel,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              if (imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      itemBuilder: (context, imageIndex) {
                        return FadeInImage.assetNetwork(
                          placeholder: 'Assets/profile_pic.png',
                          image: imageUrls[imageIndex],
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
            ],
          ),
        ),
      ),
    );
  }
}
