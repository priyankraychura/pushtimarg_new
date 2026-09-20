import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/bhajans/presentation/bhajans_screen.dart';
import '../../features/bhajans/presentation/favourites_screen.dart';
import '../../features/bhajans/presentation/search_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/lyrics/presentation/lyrics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../theme/theme.dart';
import '../widgets/container_transform_page.dart';
import 'app_routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<AsyncValue<Object?>>(const AsyncLoading());
  ref.listen(authStateProvider, (_, next) => auth.value = next, fireImmediately: true);
  ref.onDispose(auth.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final user = ref.read(authStateProvider);
      if (user.isLoading) return null;
      final signedIn = user.value != null;
      final onSignIn = state.matchedLocation == AppRoutes.signIn;
      if (!signedIn && !onSignIn) return AppRoutes.signIn;
      if (signedIn && onSignIn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (_, state) => _fade(state, const SignInScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, pageBuilder: (_, s) => _fade(s, const HomeScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.bhajans, pageBuilder: (_, s) => _fade(s, const BhajansScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.favourites, pageBuilder: (_, s) => _fade(s, const FavouritesScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.settings, pageBuilder: (_, s) => _fade(s, const SettingsScreen())),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootKey,
        // Plain fade: the Hero search bar supplies the motion.
        pageBuilder: (_, s) => _fade(s, const SearchScreen()),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, s) => _sharedAxis(s, const CalendarScreen()),
      ),
      GoRoute(
        path: AppRoutes.lyrics,
        parentNavigatorKey: _rootKey,
        // Grows out of the tapped card (passed as `extra`) and shrinks back on
        // close; falls back to a centre zoom when opened by deep link.
        pageBuilder: (_, s) => ContainerTransformPage(
          key: s.pageKey,
          origin: s.extra is ContainerOrigin ? s.extra! as ContainerOrigin : null,
          color: AppPalette.readerTop,
          child: LyricsScreen(bhajanId: s.pathParameters['id']!),
        ),
      ),
    ],
  );
});

/// Tab switches and auth fade through; pushed screens slide in on the
/// shared vertical axis. The lyrics reader grows out of its card (ContainerTransformPage).
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.normal,
      transitionsBuilder: (_, a, b, child) =>
          FadeThroughTransition(animation: a, secondaryAnimation: b, child: child),
    );

CustomTransitionPage<void> _sharedAxis(GoRouterState state, Widget child) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.slow,
      transitionsBuilder: (_, a, b, child) => SharedAxisTransition(
        animation: a,
        secondaryAnimation: b,
        transitionType: SharedAxisTransitionType.vertical,
        child: child,
      ),
    );
