import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class SyncRemoteDatasource {
  // Categories
  Future<List<Map<String, dynamic>>> fetchCloudCategories();
  Future<List<String>> pushCategories(List<Map<String, dynamic>> categories);
  Future<List<String>> deleteCloudCategories(List<String> ids);

  // Transactions
  Future<List<Map<String, dynamic>>> fetchCloudTransactions();
  Future<List<String>> pushTransactions(
    List<Map<String, dynamic>> transactions,
  );
  Future<List<String>> deleteCloudTransactions(List<String> ids);
}

class SyncRemoteDatasourceImpl implements SyncRemoteDatasource {
  final Dio _dio;
  final SharedPreferences _prefs;

  SyncRemoteDatasourceImpl({required Dio dio, required SharedPreferences prefs})
    : _dio = dio,
      _prefs = prefs;

  /// Adds the Authorization header for every authenticated call.
  Options get _authOptions => Options(
    headers: {
      'Authorization': 'Token ${_prefs.getString(AppConstants.kToken) ?? ''}',
    },
  );

  // ── Category API ──────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> fetchCloudCategories() async {
    try {
      final resp = await _dio.get(
        ApiConstants.getCategories,
        options: _authOptions,
      );
      final data = resp.data as Map<String, dynamic>;
      final list = data['categories'] as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw NetworkException(
        message:
            e.response?.data?['detail'] ??
            e.message ??
            'Failed to fetch categories',
      );
    }
  }

  @override
  Future<List<String>> pushCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    if (categories.isEmpty) return [];
    try {
      final List<String> syncedIds = [];
      // The API accepts one category per call based on the provided spec.
      // We iterate and call for each unsynced category.
      for (final cat in categories) {
        final resp = await _dio.post(
          ApiConstants.addCategory,
          data: {'category_id': cat['id'], 'name': cat['name']},
          options: _authOptions,
        );
        final data = resp.data as Map<String, dynamic>? ?? {};
        if (data['status'] == 'success') {
          if (data['synced_ids'] != null && data['synced_ids'] is List) {
            syncedIds.addAll((data['synced_ids'] as List).cast<String>());
          } else {
            syncedIds.add(cat['id'] as String);
          }
        }
      }
      return syncedIds;
    } on DioException catch (e) {
      throw NetworkException(
        message:
            e.response?.data?['detail'] ??
            e.message ??
            'Failed to sync categories',
      );
    }
  }

  @override
  Future<List<String>> deleteCloudCategories(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final resp = await _dio.delete(
        ApiConstants.deleteCategory,
        data: {'ids': ids},
        options: _authOptions,
      );
      final data = resp.data as Map<String, dynamic>? ?? {};
      if (data['deleted_ids'] != null && data['deleted_ids'] is List) {
        return (data['deleted_ids'] as List).cast<String>();
      }
      return ids; // Fallback
    } on DioException catch (e) {
      throw NetworkException(
        message:
            e.response?.data?['detail'] ??
            e.message ??
            'Failed to delete categories',
      );
    }
  }

  // ── Transaction API ───────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> fetchCloudTransactions() async {
    try {
      final resp = await _dio.get(
        ApiConstants.getTransactions,
        options: _authOptions,
      );
      final data = resp.data as Map<String, dynamic>;
      final list = data['transactions'] as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw NetworkException(
        message:
            e.response?.data?['detail'] ??
            e.message ??
            'Failed to fetch transactions',
      );
    }
  }

  @override
  Future<List<String>> pushTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    if (transactions.isEmpty) return [];
    try {
      final resp = await _dio.post(
        ApiConstants.addTransaction,
        data: {'transactions': transactions},
        options: _authOptions,
      );
      final data = resp.data as Map<String, dynamic>? ?? {};
      if (data['status'] == 'success') {
        if (data['synced_ids'] != null && data['synced_ids'] is List) {
          return (data['synced_ids'] as List).cast<String>();
        } else {
          return transactions.map((t) => t['id'] as String).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(
        message:
            e.response?.data?['detail'] ??
            e.message ??
            'Failed to sync transactions',
      );
    }
  }

  @override
  Future<List<String>> deleteCloudTransactions(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final resp = await _dio.delete(
        ApiConstants.deleteTransaction,
        data: {'ids': ids},
        options: _authOptions,
      );
      final data = resp.data as Map<String, dynamic>? ?? {};
      if (data['deleted_ids'] != null && data['deleted_ids'] is List) {
        return (data['deleted_ids'] as List).cast<String>();
      }
      return ids; // Fallback
    } on DioException catch (e) {
      throw NetworkException(
        message:
            e.response?.data?['detail'] ??
            e.message ??
            'Failed to delete transactions',
      );
    }
  }
}
