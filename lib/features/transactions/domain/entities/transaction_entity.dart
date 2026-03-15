import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String note;
  final String type; // 'credit' or 'debit'
  final String categoryId;
  final int isSynced;
  final int isDeleted;
  final DateTime timestamp;
  
  // Optional field to store the joined category name for UI display
  final String? categoryName;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.timestamp,
    this.isSynced = 0,
    this.isDeleted = 0,
    this.categoryName,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        note,
        type,
        categoryId,
        isSynced,
        isDeleted,
        timestamp,
        categoryName,
      ];

  TransactionEntity copyWith({
    String? id,
    double? amount,
    String? note,
    String? type,
    String? categoryId,
    int? isSynced,
    int? isDeleted,
    DateTime? timestamp,
    String? categoryName,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
