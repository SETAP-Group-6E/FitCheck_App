import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
                            'Terms & Conditions',
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
                            _sectionTitle('FitCheck Terms'),
                            _bodyText(
                              'Effective date: 8 March 2026. FitCheck is a student project created as part of university coursework. It is provided for educational evaluation and may change over time.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Using the App'),
                            _bodyText(
                              'By creating an account or using the app, you agree to these terms. If you do not agree, please do not use FitCheck. We may update these terms occasionally and continued use means you accept the changes.',
                            ),
                            const SizedBox(height: 10),
                            _bullet(
                              'Keep your login details safe and do not share your password.',
                            ),
                            _bullet(
                              'Use accurate information and keep your profile up to date.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Your Content'),
                            _bodyText(
                              'You are responsible for anything you upload or share. You keep ownership of your content and you allow us to display it inside the app so other users can view it.',
                            ),
                            const SizedBox(height: 10),
                            _bullet(
                              'Only post content you created or have permission to use.',
                            ),
                            _bullet(
                              'Do not upload content that is illegal, hateful or abusive.',
                            ),
                            _bullet(
                              'We may remove content that breaks these rules.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Availability'),
                            _bodyText(
                              'We cannot guarantee uninterrupted access or that all features will always be available. We may need to perform maintenance or updates that could temporarily affect access.',
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle('Changes to Terms'),
                            _bodyText(
                              'We may update these terms from time to time. If you continue using the app, you accept the updated terms.',
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
