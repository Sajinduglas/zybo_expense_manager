import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/error/exceptions.dart';

abstract class TransactionLocalDatasource {
  Future<void> insertTransaction(Map<String, dynamic> map);
  Future<List<Map<String, dynamic>>> getRecentTransactions();
  Future<List<Map<String, dynamic>>> getAllTransactions();
  Future<void> softDelete(String id);
  Future<List<Map<String, dynamic>>> getUnsynced();
  Future<List<String>> getDeletedIds();
  Future<void> permanentlyDelete(List<String> ids);
  Future<void> markSynced(List<String> ids);
  Future<double> getMonthlyDebitTotal();
}

class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  final DatabaseHelper _dbHelper;

  TransactionLocalDatasourceImpl(this._dbHelper);

  @override
  Future<void> insertTransaction(Map<String, dynamic> map) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(DbConstants.tableTransactions, map);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentTransactions() async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT
          t.${DbConstants.colId},
          t.${DbConstants.colAmount},
          t.${DbConstants.colNote},
          t.${DbConstants.colType},
          t.${DbConstants.colCategoryId},
          t.${DbConstants.colIsSynced},
          t.${DbConstants.colIsDeleted},
          t.${DbConstants.colTimestamp},
          c.${DbConstants.colName} AS category_name
        FROM ${DbConstants.tableTransactions} t
        LEFT JOIN ${DbConstants.tableCategories} c ON t.${DbConstants.colCategoryId} = c.${DbConstants.colId}
        WHERE t.${DbConstants.colIsDeleted} = 0
        ORDER BY t.${DbConstants.colTimestamp} DESC
        LIMIT 10
      ''');
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT t.*, c.${DbConstants.colName} AS category_name
        FROM ${DbConstants.tableTransactions} t
        LEFT JOIN ${DbConstants.tableCategories} c ON t.${DbConstants.colCategoryId} = c.${DbConstants.colId}
        WHERE t.${DbConstants.colIsDeleted} = 0
        ORDER BY t.${DbConstants.colTimestamp} DESC
      ''');
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> softDelete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        DbConstants.tableTransactions,
        {DbConstants.colIsDeleted: 1},
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsynced() async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        DbConstants.tableTransactions,
        where: '${DbConstants.colIsSynced} = ? AND ${DbConstants.colIsDeleted} = ?',
        whereArgs: [0, 0],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<String>> getDeletedIds() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        DbConstants.tableTransactions,
        columns: [DbConstants.colId],
        where: '${DbConstants.colIsDeleted} = ?',
        whereArgs: [1],
      );
      return result.map((row) => row[DbConstants.colId] as String).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> permanentlyDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final db = await _dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      await db.delete(
        DbConstants.tableTransactions,
        where: '${DbConstants.colId} IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final db = await _dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      await db.update(
        DbConstants.tableTransactions,
        {DbConstants.colIsSynced: 1},
        where: '${DbConstants.colId} IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<double> getMonthlyDebitTotal() async {
    try {
      final db = await _dbHelper.database;
      final start = AppDateUtils.monthStart();
      final end = AppDateUtils.monthEnd();
      final result = await db.rawQuery('''
        SELECT COALESCE(SUM(${DbConstants.colAmount}), 0) AS total
        FROM ${DbConstants.tableTransactions}
        WHERE ${DbConstants.colType} = 'debit'
          AND ${DbConstants.colIsDeleted} = 0
          AND ${DbConstants.colTimestamp} >= ? AND ${DbConstants.colTimestamp} <= ?
      ''', [start, end]);
      return (result.first['total'] as num).toDouble();
    } catch (e) {
      throw CacheException();
    }
  }
}
