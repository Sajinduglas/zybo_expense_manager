import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_manager/features/categories/presentation/bloc/category_bloc.dart';
import 'package:zybo_expense_manager/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:zybo_expense_manager/features/sync/presentation/bloc/sync_bloc.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(create: (_) => di.sl<CategoryBloc>()),
        BlocProvider<TransactionBloc>(create: (_) => di.sl<TransactionBloc>()),
        BlocProvider<SyncBloc>(create: (_) => di.sl<SyncBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Zybo Expense Manager',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
