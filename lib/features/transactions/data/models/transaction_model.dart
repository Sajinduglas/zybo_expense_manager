import '../../domain/entities/transaction_entity.dart';
import '../../../../core/constants/db_constants.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.note,
    required super.type,
    required super.categoryId,
    required super.timestamp,
    super.isSynced = 0,
    super.isDeleted = 0,
    super.categoryName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // API provides timestamp as ISO8601 string
    DateTime parsedTime;
    try {
      parsedTime = DateTime.parse(json['timestamp'] as String);
    } catch (e) {
      parsedTime = DateTime.now();
    }
    
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String,
      type: json['type'] as String,
      // API response might just have 'category' string, but for local parsing we usually map to 'category_id' if available.
      // Based on provided API docs, GET returns "category": "category name". 
      // But we need the ID for our schema. We will parse what's available.
      categoryId: json['category_id'] as String? ?? '', 
      categoryName: json['category'] as String?, 
      timestamp: parsedTime,
      isSynced: 1, // Fresh from API
      isDeleted: 0,
    );
  }

  factory TransactionModel.fromDb(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[DbConstants.colId] as String,
      amount: (map[DbConstants.colAmount] as num).toDouble(),
      note: map[DbConstants.colNote] as String,
      type: map[DbConstants.colType] as String,
      categoryId: map[DbConstants.colCategoryId] as String,
      isSynced: map[DbConstants.colIsSynced] as int,
      isDeleted: map[DbConstants.colIsDeleted] as int,
      timestamp: DateTime.parse(map[DbConstants.colTimestamp] as String),
      categoryName: map['category_name'] as String?, // From SQL JOIN
    );
  }

  Map<String, dynamic> toDb() {
    return {
      DbConstants.colId: id,
      DbConstants.colAmount: amount,
      DbConstants.colNote: note,
      DbConstants.colType: type,
      DbConstants.colCategoryId: categoryId,
      DbConstants.colIsSynced: isSynced,
      DbConstants.colIsDeleted: isDeleted,
      DbConstants.colTimestamp: timestamp.toIso8601String(),
    };
  }

  // Used for batch sync POST /transactions/add/
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': categoryId,
      // Format according to API docs: "2023-10-27 10:00:00"
      'timestamp': timestamp.toIso8601String().replaceFirst('T', ' ').substring(0, 19), 
    };
  }
}
