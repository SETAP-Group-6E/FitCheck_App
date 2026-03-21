import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color _surface = Color(0xFF1C1C1C);
  static const Color _surfaceBorder = Color(0xFF2E2E2E);
  static const Color _iconButtonBg = Color.fromRGBO(42, 42, 42, 1);

  @override
  Widget build(BuildContext context) {
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
                            'Privacy Policy',
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
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('FitCheck Privacy Policy'),
                            _bodyText(
                              'Effective date: 8 March 2026. FitCheck is a student project created as part of university coursework. This policy explains the basic information we collect and how it is used.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Information We Collect'),
                            _bodyText(
                              'We collect the information you provide when you use the app, such as:',
                            ),
                            const SizedBox(height: 10),
                            _bullet('Account details like email and username.'),
                            _bullet('Profile information you add.'),
                            _bullet('Outfits, images and captions you upload or share.'),
                            const SizedBox(height: 14),
                            _sectionTitle('How We Use Your Information'),
                            _bodyText(
                              'We use your information to provide app features, show your content and manage your account.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Sharing'),
                            _bodyText(
                              'We do not sell personal data. Your content may be visible to other users if you choose to share it inside the app. We may share information only if required by law or to operate the app.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Data Retention'),
                            _bodyText(
                              'We keep your information while your account is active. You can request deletion from the Delete account screen.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Security'),
                            _bodyText(
                              'We use reasonable technical and organisational safeguards to protect your data and limit access to authorized team members only.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Changes to This Policy'),
                            _bodyText(
                              'We may update this policy. If you continue using the app, you accept the updated policy.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Contact'),
                            _bodyText(
                              'If you have questions, use the Contact Us page in the app.',
                            ),
                          ],
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
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
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
        border: Border.all(
          color: _surfaceBorder,
          width: 1,
        ),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Georgia',
      ),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.35,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '- ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.35,
              fontFamily: 'Georgia',
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.35,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
