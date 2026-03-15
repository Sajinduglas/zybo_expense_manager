import 'package:shared_preferences/shared_preferences.dart';
import '../../../categories/data/datasources/category_local_datasource.dart';
import '../../../transactions/data/datasources/transaction_local_datasource.dart';
import '../datasources/sync_remote_datasource.dart';

/// Result object returned after a full sync operation
class SyncResult {
  final bool success;
  final String message;
  final int categoriesSynced;
  final int transactionsSynced;
  final int deletionsProcessed;

  const SyncResult({
    required this.success,
    required this.message,
    this.categoriesSynced = 0,
    this.transactionsSynced = 0,
    this.deletionsProcessed = 0,
  });
}

class SyncRepository {
  final SyncRemoteDatasource _remote;
  final CategoryLocalDatasource _categoryLocal;
  final TransactionLocalDatasource _transactionLocal;
  final SharedPreferences _prefs;

  SyncRepository({
    required SyncRemoteDatasource remote,
    required CategoryLocalDatasource categoryLocal,
    required TransactionLocalDatasource transactionLocal,
    required SharedPreferences prefs,
  })  : _remote = remote,
        _categoryLocal = categoryLocal,
        _transactionLocal = transactionLocal,
        _prefs = prefs;

  /// Full sync workflow as specified:
  /// Step A: Cloud Purge (Transactions first, then Categories)
  /// Step B: Upload new data (Categories first, then Transactions)
  Future<SyncResult> runSync() async {
    int deletionsProcessed = 0;
    int categoriesSynced = 0;
    int transactionsSynced = 0;
    final List<String> errors = [];

    // 1. Category Delete
    try {
      final deletedCatIds = await _categoryLocal.getDeletedIds();
      if (deletedCatIds.isNotEmpty) {
        final confirmedIds = await _remote.deleteCloudCategories(deletedCatIds);
        if (confirmedIds.isNotEmpty) {
          await _categoryLocal.permanentlyDelete(confirmedIds);
          deletionsProcessed += confirmedIds.length;
        }
      }
    } catch (e) {
      errors.add('Category Delete error: $e');
    }

    // 2. Category Add
    try {
      final unsyncedCatMaps = await _categoryLocal.getUnsynced();
      if (unsyncedCatMaps.isNotEmpty) {
        final payload = unsyncedCatMaps
            .map((m) => {'id': m['id'], 'name': m['name']})
            .toList();
        final syncedIds = await _remote.pushCategories(payload);
        if (syncedIds.isNotEmpty) {
          await _categoryLocal.markSynced(syncedIds);
          categoriesSynced += syncedIds.length;
        }
      }
    } catch (e) {
      errors.add('Category Add error: $e');
    }

    // 3. Transaction Delete
    try {
      final deletedTxIds = await _transactionLocal.getDeletedIds();
      if (deletedTxIds.isNotEmpty) {
        final confirmedIds = await _remote.deleteCloudTransactions(deletedTxIds);
        if (confirmedIds.isNotEmpty) {
          await _transactionLocal.permanentlyDelete(confirmedIds);
          deletionsProcessed += confirmedIds.length;
        }
      }
    } catch (e) {
      errors.add('Transaction Delete error: $e');
    }

    // 4. Transaction Add
    try {
      final unsyncedTxMaps = await _transactionLocal.getUnsynced();
      if (unsyncedTxMaps.isNotEmpty) {
        final payload = unsyncedTxMaps.map((m) {
          return {
            'id': m['id'],
            'amount': m['amount'],
            'note': m['note'],
            'type': m['type'],
            'category_id': m['category_id'],
            'timestamp': m['timestamp'],
          };
        }).toList();
        final syncedIds = await _remote.pushTransactions(payload);
        if (syncedIds.isNotEmpty) {
          await _transactionLocal.markSynced(syncedIds);
          transactionsSynced += syncedIds.length;
        }
      }
    } catch (e) {
      errors.add('Transaction Add error: $e');
    }

    // Update last-synced timestamp even if partial success
    final now = DateTime.now().toIso8601String();
    await _prefs.setString('last_synced', now);

    bool isSuccess = errors.isEmpty;
    String message = isSuccess ? 'Sync complete' : 'Sync completed with ${errors.length} errors';

    return SyncResult(
      success: true, // We return true to indicate the process finished (partial or full)
      message: message,
      categoriesSynced: categoriesSynced,
      transactionsSynced: transactionsSynced,
      deletionsProcessed: deletionsProcessed,
    );
  }

  /// Fetches all data from the cloud and populates the local SQLite databases.
  /// Used immediately after a successful login.
  Future<void> fetchFromCloud() async {
    // 1. Fetch Categories
    final cloudCats = await _remote.fetchCloudCategories();
    final Map<String, String> categoryNameToId = {};

    for (var cat in cloudCats) {
      final String catId = cat['category_id'] ?? cat['id'];
      final String catName = cat['name'];
      
      categoryNameToId[catName.toLowerCase()] = catId;

      await _categoryLocal.insertCategory({
        'id': catId,
        'name': catName,
        'is_synced': 1,
        'is_deleted': 0,
      });
    }

    // Double-check local categories in case they exist
    final localCats = await _categoryLocal.getAllCategories();
    for (var local in localCats) {
      categoryNameToId[(local['name'] as String).toLowerCase()] = local['id'] as String;
    }

    // 2. Fetch Transactions
    final cloudTxs = await _remote.fetchCloudTransactions();
    for (var tx in cloudTxs) {
      final apiCategory = tx['category'] ?? tx['category_id'] ?? '';
      final localCatId = categoryNameToId[apiCategory.toString().toLowerCase()] ?? apiCategory;

      await _transactionLocal.insertTransaction({
        'id': tx['transaction_id'] ?? tx['id'],
        'amount': (tx['amount'] as num).toDouble(),
        'note': tx['note'] ?? '',
        'type': tx['type'] ?? 'expense',
        'category_id': localCatId,
        'is_synced': 1,
        'is_deleted': 0,
        'timestamp': tx['timestamp'] ?? DateTime.now().toIso8601String(),
      });
    }

    // Update last-synced timestamp
    final now = DateTime.now().toIso8601String();
    await _prefs.setString('last_synced', now);
  }

  /// Checks if there is any unsynced or deleted data pending to be pushed to the cloud
  Future<bool> hasPendingSyncData() async {
    final deletedTxIds = await _transactionLocal.getDeletedIds();
    if (deletedTxIds.isNotEmpty) return true;

    final deletedCatIds = await _categoryLocal.getDeletedIds();
    if (deletedCatIds.isNotEmpty) return true;

    final unsyncedCatMaps = await _categoryLocal.getUnsynced();
    if (unsyncedCatMaps.isNotEmpty) return true;

    final unsyncedTxMaps = await _transactionLocal.getUnsynced();
    if (unsyncedTxMaps.isNotEmpty) return true;

    return false;
  }

  /// Returns the last synced timestamp, or null if never synced.
  String? getLastSyncedTime() {
    return _prefs.getString('last_synced');
  }
}
