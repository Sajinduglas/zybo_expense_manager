import 'package:flutter/material.dart';
import 'package:zybo_expense_manager/config/router/app_router.dart';
import 'package:zybo_expense_manager/config/theme/app_theme.dart';
import 'package:zybo_expense_manager/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
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
