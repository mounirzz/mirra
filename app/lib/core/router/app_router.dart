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
import '../../features/preferences/presentation/preferences_subscreens.dart';
import '../../features/premium/presentation/paywall_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/app_icon_screen.dart';
import '../../features/settings/presentation/widgets_guide_screen.dart';
import '../../features/topics/presentation/follow_topics_screen.dart';
import '../../features/streak/presentation/streak_hub_screen.dart';
import '../../features/theme/presentation/create_theme_screen.dart';
import '../../features/theme/presentation/theme_mixes_screen.dart';
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
        path: '/theme/mixes',
        builder: (context, state) => const ThemeMixesScreen(),
      ),
      GoRoute(
        path: '/theme/create',
        builder: (context, state) => const CreateThemeScreen(),
      ),
      GoRoute(
        path: '/streak',
        builder: (context, state) => const StreakHubScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/topics',
        builder: (context, state) => const FollowTopicsScreen(),
      ),
      GoRoute(
        path: '/app-icon',
        builder: (context, state) => const AppIconScreen(),
      ),
      GoRoute(
        path: '/widgets',
        builder: (context, state) => const WidgetsGuideScreen(),
      ),
      GoRoute(
        path: '/preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/preferences/subscription',
        builder: (context, state) => const ManageSubscriptionScreen(),
      ),
      GoRoute(
        path: '/preferences/content',
        builder: (context, state) => const ContentPrefsScreen(),
      ),
      GoRoute(
        path: '/preferences/gender',
        builder: (context, state) => const GenderScreen(),
      ),
      GoRoute(
        path: '/preferences/muted',
        builder: (context, state) => const MutedContentScreen(),
      ),
      GoRoute(
        path: '/preferences/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/preferences/name',
        builder: (context, state) => const NameScreen(),
      ),
      GoRoute(
        path: '/preferences/sound',
        builder: (context, state) => const SoundScreen(),
      ),
      GoRoute(
        path: '/preferences/reminders',
        builder: (context, state) => const RemindersScreen(),
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
