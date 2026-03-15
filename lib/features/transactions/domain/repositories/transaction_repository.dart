import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  
  // Dashboard Metrics
  Future<double> getTotalIncome();
  Future<double> getTotalExpense();
  Future<List<TransactionEntity>> getRecentTransactions(int limit);

  // Methods for sync engine
  Future<List<TransactionEntity>> getUnsyncedTransactions();
  Future<List<TransactionEntity>> getDeletedTransactions();
  Future<void> markAsSynced(List<String> ids);
  Future<void> permanentlyDelete(List<String> ids);
  Future<void> syncFromCloud(List<TransactionEntity> cloudTransactions);
}
