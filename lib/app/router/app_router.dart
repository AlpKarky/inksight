import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inksight/app/router/routes.dart';
import 'package:inksight/features/auth/domain/entities/user.dart';
import 'package:inksight/features/auth/presentation/screens/login_screen.dart';
import 'package:inksight/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Placeholder home screen until the analysis feature is migrated.
class _HomeScreenPlaceholder extends StatelessWidget {
  const _HomeScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkSight')),
      body: const Center(child: Text('Home - Analysis feature coming soon')),
    );
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref, User? currentUser) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signUp;

      if (!isLoggedIn && !isAuthRoute) return Routes.login;
      if (isLoggedIn && isAuthRoute) return Routes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const _HomeScreenPlaceholder(),
      ),
    ],
  );
}
