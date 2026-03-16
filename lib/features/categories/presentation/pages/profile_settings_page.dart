import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zybo_expense_manager/config/theme/app_colors.dart';
import 'package:zybo_expense_manager/config/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../di/injection.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';
import '../bloc/category_event.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';
import '../../../sync/data/repositories/sync_repository.dart';
import '../../../../core/database/database_helper.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/widgets/app_shimmers.dart';

import 'package:flutter_svg/flutter_svg.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _nicknameController = TextEditingController();
  final _limitController = TextEditingController();
  final _categoryController = TextEditingController();
  String _currentLimit = '10000';
  bool _editingNickname = false;
  String? _categoryError;
  String? _nicknameError;
  String? _limitError;

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _limitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = sl<SharedPreferences>();
    setState(() {
      _nicknameController.text = prefs.getString(AppConstants.kNickname) ?? '';
      _currentLimit = prefs.getString('monthly_limit') ?? '10000';
      _limitController.text = _currentLimit;
    });
  }

  Future<void> _saveNickname() async {
    final text = _nicknameController.text.trim();
    if (text.isEmpty) {
      setState(() => _nicknameError = 'Nickname cannot be empty');
      return;
    }
    final prefs = sl<SharedPreferences>();
    await prefs.setString(AppConstants.kNickname, text);
    setState(() {
      _editingNickname = false;
      _nicknameError = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nickname saved')));
    }
  }

  Future<void> _saveLimit() async {
    final text = _limitController.text.trim();
    if (text.isEmpty) {
      setState(() => _limitError = 'Limit cannot be empty');
      return;
    }
    final limit = double.tryParse(text);
    if (limit == null || limit < 0) {
      setState(() => _limitError = 'Enter a valid amount');
      return;
    }

    final prefs = sl<SharedPreferences>();
    await prefs.setString('monthly_limit', text);
    setState(() {
      _currentLimit = text;
      _limitError = null;
    });
    if (mounted) {
      context.read<TransactionBloc>().add(LoadTransactionsEvent());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Limit saved')));
    }
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isNotEmpty) {
      context.read<CategoryBloc>().add(AddCategoryEvent(name));
      _categoryController.clear();
      setState(() => _categoryError = null);
    } else {
      setState(() => _categoryError = 'Please enter a category name');
    }
  }

  void _logout() async {
    final hasPending = await sl<SyncRepository>().hasPendingSyncData();
    if (hasPending && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Unsynced Data',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'You have unsynced data. Logging out will delete all local data permanently. Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    // Clear all data
    await sl<DatabaseHelper>().clearAllData();
    final prefs = sl<SharedPreferences>();
    final onboardingDone =
        prefs.getBool(AppConstants.kOnboardingComplete) ?? false;
    await prefs.clear();
    if (onboardingDone) {
      await prefs.setBool(AppConstants.kOnboardingComplete, true);
    }

    if (mounted) context.go('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 16, 12),
            child: Text(
              'Profile & Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── NICKNAME ─────────────────────────────────────────────────────
                  _sectionHeader('NICKNAME'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.profileNicknameBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.profileBorder),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nicknameController,
                            enabled: _editingNickname,
                            autocorrect: false,
                            enableSuggestions: false,
                            cursorColor: Colors.white,
                            style: AppTextStyles.profileNickname,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_editingNickname) {
                              _saveNickname();
                            } else {
                              setState(() => _editingNickname = true);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.profileBorder,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _editingNickname
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Center(
                                    child: _svgIcon(
                                      'PencilSimple',
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_nicknameError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                        _nicknameError!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  _sectionHeader('ALERT LIMIT (₹)'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.profileNicknameBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.profileBorder),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.authFieldBackground,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.profileBorder,
                                  ),
                                ),
                                child: TextField(
                                  controller: _limitController,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  cursorColor: Colors.white,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: AppTextStyles.profileLimitHint
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: 'Amount (₹)',
                                    hintStyle: AppTextStyles.profileLimitHint
                                        .copyWith(
                                          color: AppColors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _saveLimit,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.onboardingBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Set',
                                  style: AppTextStyles.profileLimitAmount,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_limitError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              _limitError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Current Limit: ₹$_currentLimit',
                          style: AppTextStyles.profileLimitCurrent.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionHeader('CATEGORIES'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.profileNicknameBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.profileBorder),
                    ),
                    child: Column(
                      children: [
                        // Input row
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.authFieldBackground,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: _categoryController,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 13,
                                          ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: 'New category Name',
                                      hintStyle: AppTextStyles.profileHint600,
                                    ),
                                    onSubmitted: (_) => _addCategory(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _addCategory,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.onboardingBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_categoryError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _categoryError!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        // Categories list
                        BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, state) {
                            if (state is CategoryLoading) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: List.generate(
                                    4,
                                    (index) => const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: AppShimmer(
                                        width: 80,
                                        height: 36,
                                        borderRadius: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (state is CategoryLoaded) {
                              if (state.categories.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  child: Text(
                                    'No categories yet. Add one above.',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.categories.length,
                                separatorBuilder: (_, __) => const Divider(
                                  color: Colors.white10,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final cat = state.categories[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            cat.name,
                                            style:
                                                AppTextStyles.profileItemName,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context
                                              .read<CategoryBloc>()
                                              .add(DeleteCategoryEvent(cat.id)),
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.profileDeleteIconBg,
                                              border: Border.all(
                                                color: AppColors.debitRed
                                                    .withValues(alpha: 0.3),
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: _svgIcon(
                                                'TrashSimple',
                                                color: AppColors.debitRed,
                                                size: 18,
                                              ),
                                            ),
                                          ),
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
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionHeader('CLOUD SYNC'),
                  const SizedBox(height: 8),
                  BlocConsumer<SyncBloc, SyncState>(
                    listener: (context, state) {
                      if (state is SyncSuccess) {
                        final r = state.result;
                        final total = r.categoriesSynced + r.transactionsSynced + r.deletionsProcessed;
                        final hasErrors = r.errors.isNotEmpty;

                        String msg;
                        Color bg;

                        if (total == 0 && !hasErrors) {
                          msg = 'Nothing to sync — already up to date ✓';
                          bg = Colors.grey[800]!;
                        } else {
                          // Green for any actual sync (full or partial)
                          msg = 'Synced ✓  ${r.categoriesSynced} categor${r.categoriesSynced == 1 ? 'y' : 'ies'}  •  '
                              '${r.transactionsSynced} transaction${r.transactionsSynced == 1 ? '' : 's'}  •  '
                              '${r.deletionsProcessed} deletion${r.deletionsProcessed == 1 ? '' : 's'}';
                          if (hasErrors) msg += '  (${r.errors.length} item${r.errors.length == 1 ? '' : 's'} failed)';
                          bg = Colors.green[700]!;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg, style: const TextStyle(color: Colors.white)),
                            backgroundColor: bg,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else if (state is SyncFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sync failed: ${state.message}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red[700],
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isSyncing = state is SyncInProgress;
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.profileNicknameBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.profileBorder),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: isSyncing
                              ? null
                              : () => context.read<SyncBloc>().add(
                                  const TriggerSyncEvent(),
                                ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2B9B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isSyncing
                                            ? 'Syncing...'
                                            : 'Sync To Cloud',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Sync and update data to the backend',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                isSyncing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── LOGOUT ───────────────────────────────────────────────────────
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.profileNicknameBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.profileBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.power_settings_new,
                              color: Colors.red.withValues(alpha: 0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 13,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _svgIcon(
    String assetName, {
    Color color = AppColors.white,
    double size = 22,
  }) {
    return SvgPicture.asset(
      'assets/icons/$assetName.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
