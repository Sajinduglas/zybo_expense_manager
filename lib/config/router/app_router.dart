import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: RouteNames.phone,
      name: 'phone',
      builder: (context, state) =>  const Scaffold(body: Center(child: Text('phone input  Page'))),
    ),
    GoRoute(
      path: RouteNames.otp,
      name: 'otp',
      builder: (context, state) => const Scaffold(body: Center(child: Text('OTP Page'))),
    ),
    GoRoute(
      path: RouteNames.nickname,
      name: 'nickname',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Nickname'))),
    ),
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))),
    ),
    GoRoute(
      path: RouteNames.transactions,
      name: 'transactions',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Transactions'))),
    ),
    GoRoute(
      path: RouteNames.categories,
      name: 'categories',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Categories'))),
    ),
  ],
);
