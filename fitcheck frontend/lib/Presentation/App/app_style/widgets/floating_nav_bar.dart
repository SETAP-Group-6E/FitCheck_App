// FloatingNavbar: bottom-centered navigation bar used across main
// screens. Provides primary navigation icons, a central create action
// and a compact avatar that links to settings or login.
import 'dart:async';
import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_outfit.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FloatingNavbar extends StatefulWidget {
  final double width;
  final double height;
  final double bottomPadding;
  final BorderRadius borderRadius;
  final VoidCallback? onOutfitCreated;

  const FloatingNavbar({
    super.key,
    this.width = 480,
    this.height = 70,
    this.bottomPadding = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.onOutfitCreated,
  });

  @override
  State<FloatingNavbar> createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar> {
  final wardrobeRepository = SupabaseWardrobeRepository(
    Supabase.instance.client,
  );
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      _,
    ) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _navigateIfNotCurrent(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) {
      return;
    }
    Navigator.pushNamed(context, routeName);
  }

  void _openSettingsOrLogin(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    final isLoggedIn =
        auth.currentSession != null && auth.currentUser != null;
    _navigateIfNotCurrent(context, isLoggedIn ? '/my-posts' : '/login');
  }

  Widget _defaultAvatar(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.manage_accounts),
          color: Colors.black87,
          iconSize: 20,
          onPressed: () {
            _openSettingsOrLogin(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final imageUrl =
        userId == null
            ? null
            : Supabase.instance.client.storage
                .from('Avatars')
                .getPublicUrl('$userId/avatar.jpg?t=$cacheBuster');

    // The avatar URL uses a cache-busting query so updates appear
    // immediately after users change their profile picture. If the
    // user is unauthenticated we render a small default avatar that
    // links to the login/settings route.

    return Positioned(
      left: 0,
      right: 10,
      bottom: widget.bottomPadding,
      child: Center(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: widget.width,
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: SizedBox()),
              IconButton(
                icon: const Icon(Icons.home, size: 30, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/homepage');
                },
              ),
              const Expanded(child: SizedBox()),
              IconButton(
                icon: const Icon(Icons.dry_cleaning_sharp, size: 30, color: Colors.white),
                onPressed: () {
                  _navigateIfNotCurrent(context, '/wardrobe');
                },
              ),
              const Expanded(child: SizedBox()),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromRGBO(217, 156, 19, 1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 30, color: Colors.white),
                  onPressed: () async {
                    final didSave = await CreateOutfitModal.open(
                      context,
                      repository: wardrobeRepository,
                    );
                    if (didSave) {
                      widget.onOutfitCreated?.call();
                    }
                  },
                ),
              ),
              const Expanded(child: SizedBox()),

              IconButton(
                icon: const Icon(
                  Icons.explore_rounded,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  _navigateIfNotCurrent(context, '/discover');
                },
              ),
              const Expanded(child: SizedBox()),
              imageUrl == null
                  ? _defaultAvatar(context)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _defaultAvatar(context);
                            },
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _openSettingsOrLogin(context);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
