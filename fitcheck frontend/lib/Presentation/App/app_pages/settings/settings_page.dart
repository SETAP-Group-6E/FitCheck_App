// File: lib/Presentation/App/app_pages/settings/settings_page.dart
// Purpose: User settings page – account, preferences, and account actions.
// Notes: Links to sub-pages like change password/email, delete account.

// Settings page: profile + app preferences and account actions
// - Redirects to homepage when user signs out
// - Shows avatar with upload action on hover
// - Provides navigation to various settings screens (password, privacy, etc.)
// - Uses Supabase for auth and storage access
import 'dart:async';
import 'package:fitcheck/Presentation/App/app_pages/home_page.dart';
import 'package:fitcheck/Presentation/App/app_style/pfp.dart';
import 'package:flutter/material.dart';
import '../../app_style/widgets/app_toast.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/about_us_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/change_password_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/contact_us_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/delete_account_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/privacy_policy_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/terms_conditions_page.dart';
import 'package:fitcheck/Presentation/App/theme/app_theme_mode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcheck/Presentation/App/app_state.dart' as app_state;

class SettingsPage extends ConsumerStatefulWidget {
  /// Main settings screen widget.
  ///
  /// This page requires an authenticated user — it will redirect to the
  /// homepage if the session becomes unauthenticated.
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // SettingsPage state manages avatar, preferences and navigation to
  // settings sub-pages. Important behaviors:
  // - Hides the global floating navbar in initState and restores it in dispose
  // - Listens for auth state changes and navigates back to public homepage
  //   if the user signs out elsewhere
  bool _notifications = true;
  bool _isAvatarHovered = false;
  String? _avatarUrl;
  StreamSubscription<AuthState>? _authSub;
  static const Color _accent = Color.fromRGBO(217, 156, 19, 1);
  static const Color _surface = Color(0xFF1C1C1C);
  static const Color _surfaceBorder = Color(0xFF2E2E2E);
  static const Color _sectionLabel = Color(0xFF9B9B9B);
  static const Color _iconButtonBg = Color.fromRGBO(42, 42, 42, 1);

  @override
  void initState() {
    super.initState();
    _refreshAvatarUrl();
    // hide global navbar while on settings
    app_state.navbarVisible.value = false;
    // Listen for auth state changes so we can react (for example, if the
    // user signs out from another tab). When no longer authenticated we
    // navigate back to the public homepage to avoid showing protected UI.
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (!mounted) return;
      final auth = Supabase.instance.client.auth;
      final isLoggedIn =
          auth.currentSession != null && auth.currentUser != null;
      if (!isLoggedIn) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homepage',
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    // restore navbar visibility when leaving settings
    app_state.navbarVisible.value = true;
    super.dispose();
  }

  void _refreshAvatarUrl() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    // Build a cache-busted public URL for the user's avatar stored in the
    // `Avatars` storage bucket. If there's no current user, clear the URL.
    if (userId == null) {
      _avatarUrl = null;
      return;
    }

    final baseUrl = Supabase.instance.client.storage
        .from('Avatars')
        .getPublicUrl('$userId/avatar.jpg');
    // Add a timestamp query param to prevent the image from being cached
    // after an upload so the UI shows the newest avatar immediately.
    _avatarUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isLoggedIn =
        supabase.auth.currentSession != null &&
        supabase.auth.currentUser != null;
    // If user is not logged in, redirect immediately back to the public
    // homepage. We do this with a post-frame callback to avoid building
    // protected UI briefly while navigation occurs.
    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/homepage',
            (route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    final username =
        supabase.auth.currentUser?.userMetadata?['username'] ?? 'User';
    final themeMode = ref.watch(appThemeModeProvider);
    const double topBarHeight = 150;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Column(
            children: [
              // Top bar with back button, title and notifications icon
              SafeArea(
                bottom: false,
                child: Container(
                  height: topBarHeight,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Navigator.maybePop(context),
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
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              // Main scrollable content
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile details section
                        Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Avatar with hover overlay. Hovering reveals an
                              // edit button which launches the image picker and
                              // uploads the selected file to the Avatars bucket.
                              MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _isAvatarHovered = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _isAvatarHovered = false;
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _avatarUrl == null
                                        ? const CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Color(0xFF2A2A2A),
                                          child: Icon(
                                            Icons.person,
                                            size: 46,
                                            color: Colors.white,
                                          ),
                                        )
                                        : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          child: Image.network(
                                            _avatarUrl!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const CircleAvatar(
                                                radius: 50,
                                                backgroundColor: Color(
                                                  0xFF2A2A2A,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 46,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    Positioned.fill(
                                      child: AnimatedOpacity(
                                        opacity: _isAvatarHovered ? 1 : 0,
                                        duration: const Duration(
                                          milliseconds: 160,
                                        ),
                                        child: Material(
                                          color: Colors.black.withValues(
                                            alpha: 0.45,
                                          ),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () async {
                                              // Avatar upload flow: check auth, open
                                              // image picker, upload bytes to storage,
                                              // update the profile row with the new URL
                                              // and refresh the avatar shown here.
                                              final supabase =
                                                  Supabase.instance.client;
                                              final userId =
                                                  supabase.auth.currentUser?.id;
                                              if (userId == null) {
                                                if (mounted) {
                                                  showAppMessage(
                                                    context,
                                                    'Log in to upload an avatar',
                                                  );
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/login',
                                                  );
                                                }
                                                return;
                                              }

                                              final ImagePicker picker =
                                                  ImagePicker();
                                              final XFile? image = await picker
                                                  .pickImage(
                                                    source: ImageSource.gallery,
                                                  );
                                              if (image == null) return;

                                              final imageBytes =
                                                  await image.readAsBytes();
                                              final imagePath =
                                                  '$userId/avatar.jpg';

                                              try {
                                                await supabase.storage
                                                    .from('Avatars')
                                                    .uploadBinary(
                                                      imagePath,
                                                      imageBytes,
                                                      fileOptions:
                                                          const FileOptions(
                                                            contentType:
                                                                'image/jpeg',
                                                            upsert: true,
                                                          ),
                                                    );

                                                final imageUrl = supabase
                                                    .storage
                                                    .from('Avatars')
                                                    .getPublicUrl(imagePath);

                                                ProfilePicture(
                                                  onUpload: (imageUrl) async {
                                                    await supabase
                                                        .from('profiles')
                                                        .update({
                                                          'avatar_url':
                                                              imageUrl,
                                                        })
                                                        .eq('id', userId);
                                                    if (mounted) {
                                                      showAppMessage(
                                                        context,
                                                        'Uploaded to Avatars/$imagePath',
                                                      );
                                                    }
                                                  },
                                                ).onUpload(imageUrl);

                                                if (mounted) {
                                                  setState(() {
                                                    _refreshAvatarUrl();
                                                  });
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  showAppMessage(
                                                    context,
                                                    'Upload failed: $e',
                                                    error: true,
                                                  );
                                                }
                                              }
                                            },
                                            child: const Center(
                                              child: Icon(
                                                Icons.edit,
                                                size: 24,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '@$username',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                onPressed: () {
                                  // Handle username change
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Color(0xFF8A8A8A),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Change username',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

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
                                'Change password',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(
                                        name: '/settings/change_password',
                                      ),
                                      builder:
                                          (context) =>
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
                                      settings: const RouteSettings(
                                        name: '/settings/delete_account',
                                      ),
                                      builder:
                                          (context) =>
                                              const DeleteAccountPage(),
                                    ),
                                  );
                                },
                              ),
                              // 'My posts' removed per design — navigation moved to avatar and profile flows
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
                                      settings: const RouteSettings(
                                        name: '/settings/about',
                                      ),
                                      builder: (context) => const AboutUsPage(),
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
                                      settings: const RouteSettings(
                                        name: '/settings/terms',
                                      ),
                                      builder:
                                          (context) =>
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
                                      settings: const RouteSettings(
                                        name: '/settings/privacy',
                                      ),
                                      builder:
                                          (context) =>
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
                                      settings: const RouteSettings(
                                        name: '/settings/contact',
                                      ),
                                      builder:
                                          (context) => const ContactUsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 4) Preferences card
                        _buildCard(
                          child: Column(
                            children: [
                              _preferenceRow(
                                title: 'Theme',
                                trailing: GestureDetector(
                                  onTap: () async {
                                    final nextMode =
                                        themeMode == AppThemeMode.moody
                                            ? AppThemeMode.pale
                                            : AppThemeMode.moody;
                                    await ref
                                        .read(appThemeModeProvider.notifier)
                                        .setMode(nextMode);
                                  },
                                  child: _valueChip(
                                    themeMode == AppThemeMode.moody
                                        ? 'Moody'
                                        : 'Pale',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _preferenceRow(
                                title: 'Language',
                                trailing: _valueChip('English'),
                              ),
                              const SizedBox(height: 8),
                              // Notifications preference removed per UX request
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
                                color: _accent.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: const Color(0xFF1C1C1C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Log out?',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Georgia',
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Are you sure you want to log out of your account?',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              height: 1.35,
                                              fontFamily: 'Georgia',
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white70,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontFamily: 'Georgia',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _accent,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await supabase.auth
                                                        .signOut();
                                                    if (!mounted) {
                                                      return;
                                                    }
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                const HomePage(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Log out',
                                                    style: TextStyle(
                                                      fontFamily: 'Georgia',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                                    color: Colors.black.withValues(alpha: 0.18),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _surfaceBorder, width: 1),
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

  Widget _preferenceRow({required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
          trailing,
        ],
      ),
    );
  }

  Widget _valueChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
}
