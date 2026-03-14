import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class CategoryLocalDatasource {
  Future<void> insertCategory(Map<String, dynamic> map);
  Future<List<Map<String, dynamic>>> getAllCategories();
  Future<void> softDelete(String id);
  Future<List<Map<String, dynamic>>> getUnsynced();
  Future<List<String>> getDeletedIds();
  Future<void> permanentlyDelete(List<String> ids);
  Future<void> markSynced(List<String> ids);
}

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  final DatabaseHelper _dbHelper;

  CategoryLocalDatasourceImpl(this._dbHelper);

  @override
  Future<void> insertCategory(Map<String, dynamic> map) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(DbConstants.tableCategories, map);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        DbConstants.tableCategories,
        where: '${DbConstants.colIsDeleted} = ?',
        whereArgs: [0],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> softDelete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        DbConstants.tableCategories,
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
        DbConstants.tableCategories,
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
        DbConstants.tableCategories,
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
        DbConstants.tableCategories,
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
        DbConstants.tableCategories,
        {DbConstants.colIsSynced: 1},
        where: '${DbConstants.colId} IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      throw CacheException();
    }
  }
}
