import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/router/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(RouteNames.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Dark background mimicking the design
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
