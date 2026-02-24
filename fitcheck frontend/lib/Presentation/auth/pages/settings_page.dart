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
                    color: Color.fromRGBO(243, 243, 243, 1),
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
                                      color: Color.fromRGBO(155, 155, 155, 1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color.fromRGBO(111, 111, 111, 1),
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
                                      color: Color.fromRGBO(46, 46, 46, 1),
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
                              color: Color.fromRGBO(46, 46, 46, 1),
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
                                  color: Color.fromRGBO(156, 156, 156, 1),
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
                          _buildCard(
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LogoutPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 34,
                                      width: 34,
                                      decoration: const BoxDecoration(
                                        color: Color.fromRGBO(255, 205, 210, 1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.logout,
                                        size: 18,
                                        color: Color.fromRGBO(229, 57, 53, 1),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Color.fromRGBO(229, 57, 53, 1),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        fontFamily: 'Georgia',
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
        color: Color.fromRGBO(42, 42, 42, 1),
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
        color: Color.fromRGBO(234, 234, 234, 1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color.fromRGBO(189, 189, 189, 1),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _settingsRow(
    String label, {
    Color color = const Color.fromRGBO(46, 46, 46, 1),
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
            color: Color.fromRGBO(46, 46, 46, 1),
            fontFamily: 'Georgia',
          ),
        ),
        const Spacer(),
        
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color.fromRGBO(46, 46, 46, 1),
          activeTrackColor: const Color.fromRGBO(189, 189, 189, 1),
          inactiveThumbColor: const Color.fromRGBO(142, 142, 142, 1),
          inactiveTrackColor: const Color.fromRGBO(211, 211, 211, 1),
        ),
      ],
    );
  }
}
