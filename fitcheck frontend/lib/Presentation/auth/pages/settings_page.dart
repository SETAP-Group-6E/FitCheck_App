import 'package:flutter/material.dart';
import 'package:fitcheck/Presentation/auth/pages/about_us_page.dart';
import 'package:fitcheck/Presentation/auth/pages/change_email_page.dart';
import 'package:fitcheck/Presentation/auth/pages/change_password_page.dart';
import 'package:fitcheck/Presentation/auth/pages/contact_us_page.dart';
import 'package:fitcheck/Presentation/auth/pages/delete_account_page.dart';
import 'package:fitcheck/Presentation/auth/pages/logout_page.dart';
import 'package:fitcheck/Presentation/auth/pages/privacy_policy_page.dart';
import 'package:fitcheck/Presentation/auth/pages/profile_details_page.dart';
import 'package:fitcheck/Presentation/auth/pages/terms_conditions_page.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  static const Color _accent = Color.fromRGBO(217, 156, 19, 1);
  static const Color _surface = Color(0xFF1C1C1C);
  static const Color _surfaceBorder = Color(0xFF2E2E2E);
  static const Color _sectionLabel = Color(0xFF9B9B9B);
  static const Color _iconButtonBg = Color.fromRGBO(42, 42, 42, 1);

  @override
  Widget build(BuildContext context) {
    const double topBarHeight = 150;

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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                              'Settings',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ),
                        ),
                        _circleIconButton(
                          icon: Icons.notifications_none,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          // 1) Profile card
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileDetailsPage(),
                                ),
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: _buildCard(
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2F2F2F),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF3A3A3A),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Profile details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'Georgia',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Other settings',
                            style: TextStyle(
                              fontSize: 18,
                              color: _sectionLabel,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Georgia',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 2) Settings list card
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _settingsRow(
                                  'Change email',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ChangeEmailPage(),
                                      ),
                                    );
                                  },
                                ),
                                _settingsRow(
                                  'Change password',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ChangePasswordPage(),
                                      ),
                                    );
                                  },
                                ),
                                _settingsRow(
                                  'Delete account',
                                  color: _accent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DeleteAccountPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 3) Info links card
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _settingsRow(
                                  'About us',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AboutUsPage(),
                                      ),
                                    );
                                  },
                                ),
                                _settingsRow(
                                  'Terms & Conditions',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsConditionsPage(),
                                      ),
                                    );
                                  },
                                ),
                                _settingsRow(
                                  'Privacy policy',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyPolicyPage(),
                                      ),
                                    );
                                  },
                                ),
                                _settingsRow(
                                  'Contact us',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ContactUsPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 4) Switches card
                          _buildCard(
                            child: Column(
                              children: [
                                _toggleRow(
                                  title: 'Dark mode',
                                  value: _darkMode,
                                  onChanged: (value) {
                                    setState(() {
                                      _darkMode = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 6),
                                _toggleRow(
                                  title: 'Notifications',
                                  value: _notifications,
                                  onChanged: (value) {
                                    setState(() {
                                      _notifications = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 5) Logout button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LogoutPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      fontFamily: 'Georgia',
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

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _surfaceBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _settingsRow(
    String label, {
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Georgia',
          ),
        ),
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged, 
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Georgia',
          ),
        ),
        const Spacer(),
        
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF3A3A3A),
          inactiveThumbColor: const Color(0xFF8A8A8A),
          inactiveTrackColor: const Color(0xFF2B2B2B),
        ),
      ],
    );
  }
}
