// File: lib/main.dart
// Purpose: App entrypoint and route configuration for FitCheck.
// Notes: MaterialApp is configured here; persistent UI overlays live in the app shell.
//
// High-level responsibilities in this file:
// - Initialize runtime (env, Supabase)
// - Create the top-level `MaterialApp` and routing logic
// - Provide a small `NavigatorObserver` that toggles the floating
//   navigation bar visibility for specific routes

import 'package:fitcheck/Presentation/App/app_pages/home_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/wardrobe_page.dart';
import 'package:fitcheck/Presentation/auth/pages/login_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/settings/settings_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/profile/my_posts_page.dart';
import 'package:fitcheck/Presentation/App/app_pages/discover/discover_page.dart';
import 'package:fitcheck/Presentation/App/theme/app_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:fitcheck/Presentation/App/app_state.dart' as app_state;
import 'package:fitcheck/Presentation/App/app_pages/notifications_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Presentation/auth/pages/register_page.dart';
import 'Presentation/App/app_style/widgets/floating_nav_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables (development file)
  await dotenv.load(fileName: '.env/dev.txt');

  // Initialize Supabase client used by the app. These are the
  // publishable keys for development; sensitive keys are not to be
  // committed to source in production.
  const supabaseUrl = 'https://fsjkselzckrheqtqvzze.supabase.co';
  const supabaseAnonKey = 'sb_publishable_Qt6ShYvhFsUlQ4fY_LFl6A_aRLJ4Jnr';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);

    final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

    // Top-level MaterialApp. We attach a `navigatorKey` so the overlay
    // `FloatingNavbar` can use the same navigator to push routes when tapped.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitCheck',
      theme: buildAppTheme(mode),
      navigatorKey: appNavigatorKey,
      navigatorObservers: [
        NavVisibilityObserver(),
      ],
      home: HomePage(),
      builder: (context, child) {
        // The `builder` wraps every route's content in a Stack so we can
        // overlay the `FloatingNavbar` above all pages. The navbar reads the
        // shared `app_state.navbarVisible` ValueNotifier to decide
        // visibility.
        return Stack(
          children: [
            if (child != null) child,
            FloatingNavbar(navigatorKey: appNavigatorKey),
          ],
        );
      },

      // Route factory used for named navigation with custom transitions.
      // Each case returns a `PageRouteBuilder` with platform-consistent
      // transitions and the target page. We also use `settings` to
      // propagate route names so the NavVisibilityObserver can detect them.
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/homepage':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 220),
              reverseTransitionDuration: const Duration(milliseconds: 180),
              pageBuilder:
                  (context, animation, secondaryAnimation) => HomePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInQuart,
                        ),
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    FadeTransition(opacity: animation, child: child),
                  ],
                );
              },
            );

          case '/register':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const RegisterPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slideTween = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut));

                return Stack(
                  children: [
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: animation.drive(slideTween),
                      child: child,
                    ),
                  ],
                );
              },
            );
          case '/login':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 400),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              pageBuilder:
                  (context, animation, secondaryAnimation) => const LoginPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slideTween = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut));

                return Stack(
                  children: [
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: animation.drive(slideTween),
                      child: child,
                    ),
                  ],
                );
              },
            );
          // Settings screen. We check auth state and redirect to `/login`
          // if the user is not authenticated. Settings-related subpages
          // use names that start with `/settings` so the NavVisibilityObserver
          // can hide the floating navbar on those pages.
          case '/settings':
            final auth = Supabase.instance.client.auth;
            final isLoggedIn =
                auth.currentSession != null && auth.currentUser != null;

            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 280),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      isLoggedIn ? const SettingsPage() : const LoginPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slideTween = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic));

                return Stack(
                  children: [
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: animation.drive(slideTween),
                      child: child,
                    ),
                  ],
                );
              },
            );
            case '/my-posts':
                return PageRouteBuilder(
                  settings: settings,
                  transitionDuration: const Duration(milliseconds: 280),
                  reverseTransitionDuration: const Duration(milliseconds: 220),
                  pageBuilder: (context, animation, secondaryAnimation) => const MyPostsPage(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    final slideTween = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOutCubic));

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                            child: ColoredBox(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: animation.drive(slideTween),
                          child: child,
                        ),
                      ],
                    );
              },
            );
              case '/notifications':
                return PageRouteBuilder(
                  settings: settings,
                  transitionDuration: const Duration(milliseconds: 220),
                  reverseTransitionDuration: const Duration(milliseconds: 180),
                  pageBuilder: (context, animation, secondaryAnimation) => const NotificationsPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    final slideTween = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: FadeTransition(
                            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                            child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ),
                        SlideTransition(position: animation.drive(slideTween), child: child),
                      ],
                    );
                  },
                );
          case '/discover':
                  return PageRouteBuilder(
                    settings: settings,
                    transitionDuration: const Duration(milliseconds: 280),
                    reverseTransitionDuration: const Duration(milliseconds: 220),
                    pageBuilder: (context, animation, secondaryAnimation) => const DiscoverPage(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      final slideTween = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic));

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              child: ColoredBox(
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                          SlideTransition(
                            position: animation.drive(slideTween),
                            child: child,
                          ),
                        ],
                      );
                    },
                  );
          case '/wardrobe':
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 220),
              reverseTransitionDuration: const Duration(milliseconds: 180),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const WardrobePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final fadeCurve = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );
                final opacityTween = Tween<double>(begin: 0.85, end: 1.0);

                return Stack(
                  children: [
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: fadeCurve.drive(opacityTween),
                      child: child,
                    ),
                  ],
                );
              },
            );
          default:
            return null;
        }
      },
    );
  }
}

// A small navigator observer that updates `app_state.navbarVisible` based
// on route changes. It hides the floating navbar for:
// - any route whose name starts with `/settings`
// - a short list of special pages (notifications, post drafting, crop)
//
// The observer accepts anonymous routes (no name) by inspecting the
// `previousRoute` so that pushes originating from Settings keep the navbar
// hidden even when the pushed route is unnamed.
class NavVisibilityObserver extends NavigatorObserver {
  static const _hiddenRoutes = <String>{
    '/settings',
    '/notifications',
    '/post_drafting',
    '/crop',
    '/login',
    '/register',
  };

  void _update(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final name = route?.settings.name;
    // If route has no explicit name (anonymous MaterialPageRoute), don't change
    // visibility here — leave it to the originating page which may already
    // have set `navbarVisible` (for example SettingsPage). This prevents the
    // observer from overriding manual visibility flags.
    if (name == null) {
      final prevName = previousRoute?.settings.name;
      if (prevName != null && prevName.startsWith('/settings')) {
        app_state.navbarVisible.value = false;
      }
      return;
    }

    if (name.startsWith('/settings') || _hiddenRoutes.contains(name)) {
      app_state.navbarVisible.value = false;
    } else {
      app_state.navbarVisible.value = true;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    // When a new route is pushed, evaluate visibility with the current and
    // previous route so anonymous pushes can be handled.
    _update(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // After a pop, the previousRoute becomes the active route. Pass it as
    // the active route to `_update` so visibility is recalculated.
    _update(previousRoute, null);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _update(newRoute, oldRoute);
  }
}


