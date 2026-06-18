import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'screens/dashboard_screen.dart';
import 'quotes_screen.dart';
import 'new_quote_screen.dart';
import 'screens/customers_screen.dart';
import 'profile_screen.dart';
import 'package:pmpl_salesquote/main_shell.dart';
export '../models/models.dart';

class MainShell extends StatefulWidget {
  final ShowroomType showroomType;
  const MainShell({super.key, required this.showroomType});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabController.forward();
    _screens = [
      DashboardScreen(showroomType: widget.showroomType),
      QuotesScreen(showroomType: widget.showroomType),
      NewQuoteScreen(showroomType: widget.showroomType),
      CustomersScreen(showroomType: widget.showroomType),
      ProfileScreen(showroomType: widget.showroomType),
    ];
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  bool get isArena => widget.showroomType == ShowroomType.arena;
  Color get primaryColor => isArena ? AppColors.arenaMidBlue : AppColors.nexaRed;
  Color get darkColor => isArena ? AppColors.arenaNavy : AppColors.nexaCharcoal;
  Color get accentColor => isArena ? AppColors.arenaGold : AppColors.nexaAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
              _navItem(1, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Quotes'),
              _addButton(),
              _navItem(3, Icons.people_rounded, Icons.people_outline_rounded, 'Customers'),
              _navItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? primaryColor : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? primaryColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: isArena
              ? const LinearGradient(colors: [AppColors.arenaMidBlue, Color(0xFF1E40AF)])
              : const LinearGradient(colors: [AppColors.nexaRed, Color(0xFFB91C1C)]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
