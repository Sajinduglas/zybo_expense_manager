import 'package:flutter/material.dart';
import 'package:zybo_expense_manager/config/router/app_router.dart';
import 'package:zybo_expense_manager/config/theme/app_theme.dart';
import 'package:zybo_expense_manager/di/injection.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

late GoRouter appRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  final prefs = await SharedPreferences.getInstance();
  appRouter = createRouter(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zybo Expense Manager',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
