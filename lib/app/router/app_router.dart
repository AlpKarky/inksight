import 'package:go_router/go_router.dart';
import 'package:inksight/app/router/routes.dart';
import 'package:inksight/features/analysis/presentation/screens/history_screen.dart';
import 'package:inksight/features/analysis/presentation/screens/home_screen.dart';
import 'package:inksight/features/analysis/presentation/screens/result_screen.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/presentation/screens/login_screen.dart';
import 'package:inksight/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref, UserEntity? currentUser) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isAuthRoute =
          state.matchedLocation == Routes.login ||
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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.result,
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: Routes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
}
