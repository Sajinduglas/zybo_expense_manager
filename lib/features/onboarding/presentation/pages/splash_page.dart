import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../config/router/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final hasToken = (prefs.getString(AppConstants.kToken) ?? '').isNotEmpty;
    final hasNickname = (prefs.getString(AppConstants.kNickname) ?? '').isNotEmpty;
    final onboardingDone = prefs.getBool(AppConstants.kOnboardingComplete) ?? false;

    if (!mounted) return;

    if (hasToken && hasNickname) {
      context.go(RouteNames.home);
    } else if (hasToken && !hasNickname) {
      context.go(RouteNames.nickname);
    } else if (onboardingDone) {
      context.go(RouteNames.phone);
    } else {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 133,
          height: 104,
        ),
      ),
    );
  }
}
