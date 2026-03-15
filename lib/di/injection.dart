import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/api_constants.dart';
import '../core/database/database_helper.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

import '../features/categories/data/datasources/category_local_datasource.dart';
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/presentation/bloc/category_bloc.dart';

import '../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/presentation/bloc/transaction_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => const Uuid());

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
  ));
  sl.registerLazySingleton(() => dio);

  // Auth
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(dio: sl()),
  );
  sl.registerLazySingleton(
    () => AuthRepository(remoteDatasource: sl(), prefs: sl()),
  );
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Category
  sl.registerLazySingleton<CategoryLocalDatasource>(
    () => CategoryLocalDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDatasource: sl(), uuid: sl()),
  );
  sl.registerFactory(() => CategoryBloc(repository: sl()));

  // Transaction
  sl.registerLazySingleton<TransactionLocalDatasource>(
    () => TransactionLocalDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDatasource: sl(), uuid: sl()),
  );
  sl.registerFactory(() => TransactionBloc(repository: sl()));
}

