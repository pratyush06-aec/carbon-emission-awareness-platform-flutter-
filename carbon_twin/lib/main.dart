import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/navigation/presentation/navigation_screen.dart';
import 'features/analyze/presentation/analyze_screen.dart';
import 'features/learn/presentation/learn_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CarbonTwinApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class CarbonTwinApp extends ConsumerWidget {
  const CarbonTwinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuth = authState.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        final isOnboarding = state.matchedLocation == '/onboarding';

        if (!isAuth && !isAuthRoute) return '/login';
        if (isAuth && isAuthRoute) return '/home';

        return null;
      },
      routes: [
        // Auth routes (no bottom nav)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Main app routes (with bottom nav shell)
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/navigate',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NavigationScreen(),
              ),
            ),
            GoRoute(
              path: '/analyze',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AnalyzeScreen(),
              ),
            ),
            GoRoute(
              path: '/learn',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LearnScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'CarbonTwin AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
