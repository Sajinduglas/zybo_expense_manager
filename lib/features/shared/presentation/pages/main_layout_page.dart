import 'package:flutter/material.dart';
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

  static const Color _background = Color(0xFF141414);
  static const Color _activeBlue = Color(0xFF3B38D0);
  static const Color _navBg = Color(0xFF1E1E1E);

  // Pages
  final List<Widget> _pages = const [
    HomePage(),          // index 0 – Home / Dashboard
    TransactionsPage(),  // index 1 – All Transactions
    ProfileSettingsPage(), // index 2 – Profile & Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // FAB only on Home tab
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => AddTransactionSheet.show(context),
              backgroundColor: const Color(0xFF4CAF50),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                _navItem(0, Icons.pie_chart, Icons.pie_chart_outline),
                _navItem(1, Icons.sync, Icons.sync),
                _navItem(2, Icons.settings, Icons.settings_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon) {
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
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? Colors.white : Colors.white54,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
