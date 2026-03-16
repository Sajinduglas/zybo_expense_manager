import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zybo_expense_manager/config/theme/app_colors.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../categories/presentation/pages/profile_settings_page.dart';
import '../../../transactions/presentation/pages/add_transaction_sheet.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _currentIndex = 0;

  static const Color _activeBlue = AppColors.blue;
  static const Color _navBg = AppColors.darkSurface;
  static const Color _background = AppColors.scafoldBackground;

  // Pages
  final List<Widget> _pages = const [
    HomePage(), // index 0 – Home / Dashboard
    TransactionsPage(), // index 1 – All Transactions
    ProfileSettingsPage(), // index 2 – Profile & Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: IndexedStack(index: _currentIndex, children: _pages),

      // FAB only on Home tab
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => AddTransactionSheet.show(context),
              backgroundColor:Color(0xFF20DE39),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: AppColors.white, size: 28),
            )
          : null,

      // Bottom nav bar matching Figma
      bottomNavigationBar: Container(
        color: _background,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: SafeArea(
          top: false,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: _navBg,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, 'bottom_nav_1'),
                _navItem(1, 'bottom_nav_2'),
                _navItem(2, 'bottom_nav_3'),
              ],
            ),
          ),
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

  Widget _navItem(int index, String svgName) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 64,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 52 : 44,
            height: isActive ? 52 : 44,
            decoration: BoxDecoration(
              color: isActive ? _activeBlue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _svgIcon(
                svgName,
                color: isActive
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
