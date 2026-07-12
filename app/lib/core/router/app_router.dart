import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mix/presentation/mix_screen.dart';
import '../../features/my_quotes/presentation/my_quotes_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/preferences/presentation/preferences_screen.dart';
import '../../features/premium/presentation/paywall_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/theme/presentation/theme_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final completed = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: completed ? '/home' : '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(path: '/mix', builder: (context, state) => const MixScreen()),
      GoRoute(
        path: '/my-quotes',
        builder: (context, state) => const MyQuotesScreen(),
      ),
      GoRoute(path: '/theme', builder: (context, state) => const ThemeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => PaywallScreen(
          fromOnboarding: state.uri.queryParameters['from'] == 'onboarding',
        ),
      ),
    ],
  );
});
