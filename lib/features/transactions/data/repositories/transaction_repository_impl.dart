import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource localDatasource;
  final Uuid uuid;

  TransactionRepositoryImpl({
    required this.localDatasource,
    this.uuid = const Uuid(),
  });

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final maps = await localDatasource.getAllTransactions();
    return maps.map((map) => TransactionModel.fromDb(map)).toList();
  }

  @override
  Future<TransactionEntity> addTransaction(TransactionEntity transaction) async {
    // If ID is empty or needs generation, though it's required in constructor
    final String id = transaction.id.isEmpty ? uuid.v4() : transaction.id;
    
    final model = TransactionModel(
      id: id,
      amount: transaction.amount,
      note: transaction.note,
      type: transaction.type,
      categoryId: transaction.categoryId,
      timestamp: transaction.timestamp,
      isSynced: 0,
      isDeleted: 0,
    );
    
    await localDatasource.insertTransaction(model.toDb());
    return model;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDatasource.softDelete(id);
  }

  @override
  Future<double> getTotalIncome() async {
    final maps = await localDatasource.getAllTransactions();
    double total = 0;
    for (var map in maps) {
      if (map['type'] == 'credit' && map['is_deleted'] == 0) {
        total += (map['amount'] as num).toDouble();
      }
    }
    return total;
  }

  @override
  Future<double> getTotalExpense() async {
    final maps = await localDatasource.getAllTransactions();
    double total = 0;
    for (var map in maps) {
      if (map['type'] == 'debit' && map['is_deleted'] == 0) {
        total += (map['amount'] as num).toDouble();
      }
    }
    return total;
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions(int limit) async {
    final maps = await localDatasource.getRecentTransactions();
    return maps.map((map) => TransactionModel.fromDb(map)).take(limit).toList();
  }

  @override
  Future<List<TransactionEntity>> getUnsyncedTransactions() async {
    final maps = await localDatasource.getUnsynced();
    return maps.map((map) => TransactionModel.fromDb(map)).toList();
  }

  @override
  Future<List<TransactionEntity>> getDeletedTransactions() async {
    throw UnimplementedError("Modify local datasource if full deleted objects are needed");
  }

  @override
  Future<void> markAsSynced(List<String> ids) async {
    await localDatasource.markSynced(ids);
  }

  @override
  Future<void> permanentlyDelete(List<String> ids) async {
    await localDatasource.permanentlyDelete(ids);
  }

  @override
  Future<void> syncFromCloud(List<TransactionEntity> cloudTransactions) async {
     for (var entity in cloudTransactions) {
       final model = TransactionModel(
         id: entity.id,
         amount: entity.amount,
         note: entity.note,
         type: entity.type,
         categoryId: entity.categoryId,
         timestamp: entity.timestamp,
         isSynced: 1, // Fresh from API
         isDeleted: 0,
       );
       await localDatasource.insertTransaction(model.toDb());
    }
  }
}
