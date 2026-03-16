import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_text_styles.dart';

import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../shared/presentation/widgets/app_shimmers.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CategoryBloc>()),
          BlocProvider.value(value: context.read<TransactionBloc>()),
        ],
        child: const AddTransactionSheet(),
      ),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool _isExpense = true;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;

  // Inline error state
  String? _titleError;
  String? _amountError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    // Run all validations and collect inline errors
    setState(() {
      _titleError = title.isEmpty ? 'Title is required' : null;

      if (amountText.isEmpty) {
        _amountError = 'Amount is required';
      } else if (amount == null || amount <= 0) {
        _amountError = 'Enter a valid positive amount';
      } else {
        _amountError = null;
      }

      _categoryError = _selectedCategoryId == null ? 'Please select a category' : null;
    });

    // Stop if any error exists
    if (_titleError != null || _amountError != null || _categoryError != null) return;

    final transaction = TransactionEntity(
      id: '',
      amount: amount!,
      note: title,
      type: _isExpense ? 'debit' : 'credit',
      categoryId: _selectedCategoryId!,
      timestamp: DateTime.now(),
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    const Color greenColor = Color(0xFF1CB43E);
    const Color inputBackground = Color(0xFF2A2A2A);
    const Color blueColor = Color(0xFF3B38D0);
    const Color errorColor = Color(0xFFFF5252);

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset, left: 24, right: 24, top: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Transaction', style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 20)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text('Close', style: AppTextStyles.body.copyWith(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Type Toggle ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isExpense = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isExpense ? greenColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('Expense', style: AppTextStyles.button.copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isExpense = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isExpense ? greenColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Income',
                          style: AppTextStyles.button.copyWith(
                            color: !_isExpense ? Colors.white : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Title Field ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: _titleError != null
                    ? Border.all(color: errorColor, width: 1.2)
                    : null,
              ),
              child: TextField(
                controller: _titleController,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintText: 'Title ',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if (_titleError != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(_titleError!, style: const TextStyle(color: errorColor, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 16),

            // ── Amount Field ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: _amountError != null
                    ? Border.all(color: errorColor, width: 1.2)
                    : null,
              ),
              child: TextField(
                controller: _amountController,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: Colors.white,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (_) {
                  if (_amountError != null) setState(() => _amountError = null);
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintText: 'Amount ( ₹ )',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if (_amountError != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(_amountError!, style: const TextStyle(color: errorColor, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 20),

            // ── Category Section ─────────────────────────────────────────────
            Text('CATEGORY', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
            const SizedBox(height: 10),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: AppShimmer(width: 80, height: 36, borderRadius: 8),
                      )),
                    ),
                  );
                }
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return Text('No categories. Add from Profile.',
                        style: AppTextStyles.body.copyWith(color: Colors.white54));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.categories.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategoryId = cat.id;
                            _categoryError = null; // Clear error on selection
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? blueColor.withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? blueColor
                                    : _categoryError != null
                                        ? errorColor
                                        : Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(cat.name, style: AppTextStyles.body.copyWith(color: Colors.white)),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (_categoryError != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(_categoryError!, style: const TextStyle(color: errorColor, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 20),

            // ── Info Banner ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF132915),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Everything you add here is saved only on your device.',
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Save Button ──────────────────────────────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _onSave,
              child: Text('Save', style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
