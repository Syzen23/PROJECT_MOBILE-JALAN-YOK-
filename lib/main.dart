import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/onboarding_screen.dart';
import 'features/auth/presentation/pages/auth_options_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/plan/presentation/pages/plan_screen.dart';
import 'features/history/presentation/pages/history_screen.dart';
import 'features/profile/presentation/pages/profile_screen.dart';
import 'features/search/presentation/pages/search_screen.dart';
import 'widgets/scaffold_with_nav_bar.dart';

import 'package:firebase_core/firebase_core.dart';
import 'features/admin/presentation/widgets/admin_scaffold.dart';
import 'features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'features/admin/presentation/pages/admin_destinations_screen.dart';
import 'features/admin/presentation/pages/admin_users_screen.dart';
import 'features/admin/presentation/pages/destination_form_screen.dart';
import 'core/models/destination_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHome = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final GlobalKey<NavigatorState> _shellNavigatorPlan = GlobalKey<NavigatorState>(
  debugLabel: 'shellPlan',
);
final GlobalKey<NavigatorState> _shellNavigatorHistory =
    GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
final GlobalKey<NavigatorState> _shellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

// Admin Navigators
final GlobalKey<NavigatorState> _shellNavigatorAdminDashboard = 
    GlobalKey<NavigatorState>(debugLabel: 'shellAdminDashboard');
final GlobalKey<NavigatorState> _shellNavigatorAdminDestinations = 
    GlobalKey<NavigatorState>(debugLabel: 'shellAdminDestinations');
final GlobalKey<NavigatorState> _shellNavigatorAdminUsers = 
    GlobalKey<NavigatorState>(debugLabel: 'shellAdminUsers');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        // Splash screen acts as the initial route. We can use a Future.delayed to navigate
        // to auth options, but for now we'll just display it and let the user tap to continue,
        // or automatically redirect after 2 seconds.
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/onboarding');
          }
        });
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/auth-options',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthOptionsScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const SearchScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Beranda
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHome,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 2: Rencana
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPlan,
          routes: [
            GoRoute(
              path: '/plan',
              builder: (context, state) => const PlanScreen(),
            ),
          ],
        ),
        // Tab 3: Riwayat
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHistory,
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // Tab 4: Saya (Profile)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfile,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Admin Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdminScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAdminDashboard,
          routes: [
            GoRoute(
              path: '/admin_home',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAdminDestinations,
          routes: [
            GoRoute(
              path: '/admin_destinations',
              builder: (context, state) => const AdminDestinationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAdminUsers,
          routes: [
            GoRoute(
              path: '/admin_users',
              builder: (context, state) => const AdminUsersScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/admin/destination-form',
      builder: (context, state) {
        final dest = state.extra as Destination?;
        return DestinationFormScreen(destination: dest);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'JalanYok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          primary: const Color(0xFF007AFF),
          surface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        useMaterial3: true,
      ),
    );
  }
}
