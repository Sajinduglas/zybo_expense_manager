import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  
  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> allTransactions;
  final List<TransactionEntity> recentTransactions;
  final double totalIncome;
  final double totalExpense;

  const TransactionLoaded({
    required this.allTransactions,
    required this.recentTransactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object> get props => [
    allTransactions,
    recentTransactions,
    totalIncome,
    totalExpense,
  ];

  TransactionLoaded copyWith({
    List<TransactionEntity>? allTransactions,
    List<TransactionEntity>? recentTransactions,
    double? totalIncome,
    double? totalExpense,
  }) {
    return TransactionLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}
