import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/db_constants.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), DbConstants.dbName);
    return await openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableCategories} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colIsSynced} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colIsDeleted} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableTransactions} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colAmount} REAL NOT NULL,
        ${DbConstants.colNote} TEXT,
        ${DbConstants.colType} TEXT NOT NULL,
        ${DbConstants.colCategoryId} TEXT NOT NULL,
        ${DbConstants.colIsSynced} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colIsDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colTimestamp} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colCategoryId}) REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
      )
    ''');
  }
}
