import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../di/injection.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../shared/presentation/widgets/app_shimmers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day;
    final suffix = (day == 1 || day == 21 || day == 31)
        ? 'st'
        : (day == 2 || day == 22)
            ? 'nd'
            : (day == 3 || day == 23)
                ? 'rd'
                : 'th';
    return '$day$suffix ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        final prefs = sl<SharedPreferences>();
        final nickname = prefs.getString(AppConstants.kNickname) ?? 'User';
        final monthlyLimit = double.tryParse(prefs.getString('monthly_limit') ?? '10000') ?? 10000;

        final bool isLoading = txState is TransactionLoading || txState is TransactionInitial;

        double income = 0;
        double expense = 0;
        if (txState is TransactionLoaded) {
          income = txState.totalIncome;
          expense = txState.totalExpense;
        }

        final progress = monthlyLimit > 0 ? (expense / monthlyLimit).clamp(0.0, 1.0) : 0.0;
        final remaining = ((monthlyLimit - expense) / monthlyLimit * 100).clamp(0, 100).toStringAsFixed(0);

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  '👋 Welcome, $nickname!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── Income / Expense Cards ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: isLoading 
                        ? const BalanceCardShimmer()
                        : _balanceCard(
                          title: 'Total Income',
                          amount: income,
                          color: const Color(0xFF165A15),
                          icon: Icons.arrow_downward,
                        ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: isLoading
                        ? const BalanceCardShimmer()
                        : _balanceCard(
                          title: 'Total Expense',
                          amount: expense,
                          color: const Color(0xFF8B0000),
                          icon: Icons.arrow_upward,
                        ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Monthly Limit Progress ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: isLoading 
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 100, height: 10),
                          SizedBox(height: 12),
                          AppShimmer(width: 180, height: 20),
                          SizedBox(height: 16),
                          AppShimmer(width: double.infinity, height: 8, borderRadius: 4),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MONTHLY LIMIT',
                            style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${expense.toStringAsFixed(0)} / ₹${monthlyLimit.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                expense >= monthlyLimit ? Colors.red : const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$remaining% Remaining',
                            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                          ),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Recent Transactions Header ────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // ── Transaction List ──────────────────────────────────────────
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (isLoading) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, __) => const TransactionItemShimmer(),
                      );
                    }
                    if (txState is TransactionLoaded) {
                      if (txState.recentTransactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long, color: Color(0xFF444444), size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions yet.',
                                style: TextStyle(color: Colors.white38, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: txState.recentTransactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = txState.recentTransactions[index];
                          final isCredit = tx.type == 'credit';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white60,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name + Category
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tx.note,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tx.categoryName ?? 'Uncategorized',
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Date + Amount + Delete
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDate(tx.timestamp),
                                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: isCredit ? const Color(0xFF4CAF50) : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                // Delete
                                GestureDetector(
                                  onTap: () => context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id)),
                                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _balanceCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
