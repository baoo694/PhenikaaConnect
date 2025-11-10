import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'academic_screen.dart';
import 'social_screen.dart';
import 'campus_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
              );
            },
            child: IndexedStack(
              key: ValueKey(appProvider.selectedTabIndex),
              index: appProvider.selectedTabIndex,
              children: const [
                HomeScreen(),
                AcademicScreen(),
                SocialScreen(),
                CampusScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      icon: LucideIcons.home,
                      label: 'Trang chủ',
                      index: 0,
                      isSelected: appProvider.selectedTabIndex == 0,
                      onTap: () => appProvider.setSelectedTab(0),
                    ),
                    _buildNavItem(
                      context,
                      icon: LucideIcons.bookOpen,
                      label: 'Học tập',
                      index: 1,
                      isSelected: appProvider.selectedTabIndex == 1,
                      onTap: () => appProvider.setSelectedTab(1),
                    ),
                    _buildNavItem(
                      context,
                      icon: LucideIcons.users,
                      label: 'Cộng đồng',
                      index: 2,
                      isSelected: appProvider.selectedTabIndex == 2,
                      onTap: () => appProvider.setSelectedTab(2),
                    ),
                    _buildNavItem(
                      context,
                      icon: LucideIcons.mapPin,
                      label: 'Đời sống',
                      index: 3,
                      isSelected: appProvider.selectedTabIndex == 3,
                      onTap: () => appProvider.setSelectedTab(3),
                    ),
                    _buildNavItem(
                      context,
                      icon: LucideIcons.user,
                      label: 'Cá nhân',
                      index: 4,
                      isSelected: appProvider.selectedTabIndex == 4,
                      onTap: () => appProvider.setSelectedTab(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
