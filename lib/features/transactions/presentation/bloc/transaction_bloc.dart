import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';

import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _emitFullState(emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransactionEvent event, Emitter<TransactionState> emit) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      
      // Optimistic Update
      final newAll = List.of(currentState.allTransactions)..insert(0, event.transaction);
      final newRecent = List.of(currentState.recentTransactions)..insert(0, event.transaction);
      if (newRecent.length > 10) newRecent.removeLast(); // Keep recent transactions limited
      
      final incomeChange = event.transaction.type == 'credit' ? event.transaction.amount : 0;
      final expenseChange = event.transaction.type == 'debit' ? event.transaction.amount : 0;
      
      emit(currentState.copyWith(
        allTransactions: newAll,
        recentTransactions: newRecent,
        totalIncome: currentState.totalIncome + incomeChange,
        totalExpense: currentState.totalExpense + expenseChange,
      ));

      try {
        await repository.addTransaction(event.transaction);
        // Sync complete, re-fetch completely to get actual SQlite state with properly mapped Categories
        await _emitFullState(emit);
      } catch (e) {
        emit(TransactionError("Failed to add transaction"));
        emit(currentState); // Rollback
      }
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      
      try {
        final transactionToDelete = currentState.allTransactions.firstWhere((t) => t.id == event.id);
        
        // Optimistic Delete
        final newAll = currentState.allTransactions.where((t) => t.id != event.id).toList();
        final newRecent = currentState.recentTransactions.where((t) => t.id != event.id).toList();
        
        final incomeChange = transactionToDelete.type == 'credit' ? transactionToDelete.amount : 0;
        final expenseChange = transactionToDelete.type == 'debit' ? transactionToDelete.amount : 0;
        
        emit(currentState.copyWith(
          allTransactions: newAll,
          recentTransactions: newRecent, // We won't re-fill up to 10 immediately until real fetch
          totalIncome: currentState.totalIncome - incomeChange,
          totalExpense: currentState.totalExpense - expenseChange,
        ));

        await repository.deleteTransaction(event.id);
        await _emitFullState(emit); // Refresh perfectly from DB
      } catch (e) {
        emit(TransactionError("Failed to delete transaction"));
        emit(currentState); // Rollback
      }
    }
  }

  // Refetches completely from local database
  Future<void> _emitFullState(Emitter<TransactionState> emit) async {
    final all = await repository.getTransactions();
    final recent = await repository.getRecentTransactions(10);
    final income = await repository.getTotalIncome();
    final expense = await repository.getTotalExpense();

    emit(TransactionLoaded(
      allTransactions: all,
      recentTransactions: recent,
      totalIncome: income,
      totalExpense: expense,
    ));
  }
}
