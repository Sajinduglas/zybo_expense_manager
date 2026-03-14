import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'route_names.dart';
import '../../core/constants/app_constants.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/phone_input_page.dart';
import '../../features/auth/presentation/pages/nickname_page.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// Reads SharedPreferences synchronously after init (prefs already populated).
GoRouter createRouter(SharedPreferences prefs) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final path = state.matchedLocation;
      
      // Never redirect from splash — it handles its own logic
      if (path == RouteNames.splash) return null;

      final hasToken = (prefs.getString(AppConstants.kToken) ?? '').isNotEmpty;
      final hasNickname = (prefs.getString(AppConstants.kNickname) ?? '').isNotEmpty;
      final onboardingDone = prefs.getBool(AppConstants.kOnboardingComplete) ?? false;

      // Not logged in
      if (!hasToken) {
        if (!onboardingDone && path != RouteNames.onboarding) return RouteNames.onboarding;
        if (onboardingDone &&
            path != RouteNames.phone &&
            path != RouteNames.nickname) {
          return RouteNames.phone;
        }
        return null;
      }

      // Logged in but no nickname yet
      if (hasToken && !hasNickname) {
        if (path != RouteNames.nickname) return RouteNames.nickname;
        return null;
      }

      // Fully authenticated — block auth routes
      if (path == RouteNames.onboarding ||
          path == RouteNames.phone ||
          path == RouteNames.nickname) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.phone,
        builder: (context, state) => const PhoneInputPage(),
      ),
      GoRoute(
        path: RouteNames.nickname,
        builder: (context, state) {
          // Extra is populated when navigating from PhoneInputPage (new user flow)
          // It may be null when the redirect sends here (incomplete profile detected at startup)
          final nicknameState = state.extra as NicknameRequired?;
          final phone = nicknameState?.phone ?? prefs.getString(AppConstants.kPhone) ?? '';
          return NicknamePage(
            nicknameState: NicknameRequired(phone: phone),
          );
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const Scaffold(
          backgroundColor: Color(0xFF141414),
          body: Center(child: Text('Home', style: TextStyle(color: Colors.white))),
        ),
      ),
      GoRoute(
        path: RouteNames.transactions,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Transactions')),
        ),
      ),
      GoRoute(
        path: RouteNames.categories,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Categories')),
        ),
      ),
    ],
  );
}
