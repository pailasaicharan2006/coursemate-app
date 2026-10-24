import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: AppTheme.darkBgMain,
            body: Row(
              children: [
                _buildNavRail(context),
                // Subtle vertical divider
                Container(
                  width: 1,
                  color: AppTheme.darkBorderCyan,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        // Mobile: bottom navigation bar with glassmorphism background
        return Scaffold(
          backgroundColor: AppTheme.darkBgMain,
          body: navigationShell,
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  // ── Desktop navigation rail ────────────────────────────────────────────────

  Widget _buildNavRail(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppTheme.darkCardBg.withValues(alpha: 0.92),
          child: NavigationRail(
            backgroundColor: Colors.transparent,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, index),
            labelType: NavigationRailLabelType.all,
            minWidth: 88,
            selectedIconTheme: const IconThemeData(
              color: AppTheme.cyanPrimary,
              size: 26,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppTheme.darkTextSecondary,
              size: 24,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppTheme.cyanPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppTheme.darkTextSecondary,
              fontSize: 12,
            ),
            indicatorColor: AppTheme.cyanPrimary.withValues(alpha: 0.12),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  // Cyan accent line at top of leading
                  Container(
                    width: 36,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.cyanPrimary, AppTheme.cyanSecondary],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Course',
                    style: TextStyle(
                      color: AppTheme.darkTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Text(
                    'Mate',
                    style: TextStyle(
                      color: AppTheme.cyanPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Discover'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: Text('Saved'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Learning'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile bottom navigation bar ──────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCardBg,
        border: const Border(
          top: BorderSide(color: AppTheme.darkBorderCyan, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.cyanPrimary,
        unselectedItemColor: AppTheme.darkTextSecondary,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Learning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
