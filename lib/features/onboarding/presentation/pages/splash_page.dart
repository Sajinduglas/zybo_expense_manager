import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zybo_expense_manager/config/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../config/router/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../di/injection.dart' as di;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Artificial delay
    await Future.delayed(const Duration(seconds: 2));

    print('[SPLASH] About to call requestPermissions()');
    // Request push notification permissions once UI is alive
    await NotificationService().requestPermissions();
    print('[SPLASH] requestPermissions() done');

    // Now proceed with navigation
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = di.sl<SharedPreferences>(); // Using DI for SharedPreferences
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
      backgroundColor: AppColors.darkBackground,
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
