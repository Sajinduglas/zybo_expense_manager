class DbConstants {
  static const String dbName = 'expense_manager.db';
  static const int dbVersion = 1;

  // Tables
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';

  // Common Columns
  static const String colId = 'id';
  static const String colIsSynced = 'is_synced';
  static const String colIsDeleted = 'is_deleted';

  // Category Columns
  static const String colName = 'name';

  // Transaction Columns
  static const String colAmount = 'amount';
  static const String colNote = 'note';
  static const String colType = 'type';
  static const String colCategoryId = 'category_id';
  static const String colTimestamp = 'timestamp';
}
