import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDetailsPage extends StatelessWidget {
  ProfileDetailsPage({super.key});

  static const Color _accent = Color.fromRGBO(217, 156, 19, 1);
  static const Color _surface = Color(0xFF1C1C1C);
  static const Color _surfaceBorder = Color(0xFF2E2E2E);
  static const Color _iconButtonBg = Color.fromRGBO(42, 42, 42, 1);
  
  @override
  Widget build(BuildContext context) {

    final username =
      Supabase.instance.client.auth.currentUser?.userMetadata?['username'] ??
      'User';

    const double topBarHeight = 120;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  height: topBarHeight,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  color: Colors.black,
                  child: Row(
                    children: [
                      _circleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Profile details',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40, width: 40),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                
                                    CircleAvatar(
                                      radius: 44,
                                      backgroundColor: const Color(0xFF2A2A2A),
                                      child: 
                                          Icon(
                                            Icons.person,
                                            size: 46,
                                            color: Colors.white,
                                          ),
                                        
                                    ),
                                     
                                const SizedBox(height: 12),
                                const Text(
                                  'Mark Wardrobe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Georgia',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '@$username',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: 'Georgia',
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                                        top: 62,
                                        left: 92,
                                        
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor:Colors.grey[700],
                                          child: IconButton(
                                            icon: Icon( 
                                              Icons.edit,
                                              size: 15,
                                              color: Colors.white70,
                                              
                                            ), onPressed: () { null; },
                                            style: IconButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(24, 24),
                                            ),
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _StatItem(label: 'Outfits', value: '34'),
                            _StatItem(label: 'Posts', value: '128'),
                            _StatItem(label: 'Likes', value: '2.3K'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Casual streetwear with a love for neutrals and clean layers.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.35,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _TagChip(label: 'Streetwear'),
                                _TagChip(label: 'Minimal'),
                                _TagChip(label: 'Neutral tones'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Edit profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _iconButtonBg,
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _surfaceBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'Georgia',
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
}
