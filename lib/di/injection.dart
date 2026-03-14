import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core Services
  // will register Dio, DatabaseHelper, NotificationService, SharedPreferences here
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Auth 
  // will register Auth datasource, repo, usecases, bloc here
  // Categories
  // will register Categories datasource, repo, usecases, bloc here
  // Transactions
  // will register Transactions datasource, repo, usecases, bloc here
  // Sync
  // will register Sync repo, usecases, bloc here
}
