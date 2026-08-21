import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/watchlist_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlistCount = ref.watch(watchlistProvider).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const HomeScreen(),
      const SearchScreen(),
      WatchlistScreen(
        onExploreMovies: () => _onTabSelected(0),
      ),
    ];

    return Scaffold(
      extendBody: true, // Enables underlying content to show beneath frosted bar
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: isDark
                      ? const Color(0xFF151D2E).withValues(alpha: 0.72)
                      : Colors.white.withValues(alpha: 0.78),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Trending',
                      icon: Icons.movie_outlined,
                      selectedIcon: Icons.movie_rounded,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'Search',
                      icon: Icons.search_rounded,
                      selectedIcon: Icons.search_rounded,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'Watchlist',
                      icon: Icons.bookmark_outline_rounded,
                      selectedIcon: Icons.bookmark_rounded,
                      badgeCount: watchlistCount,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required bool isDark,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: isDark ? 0.22 : 0.18)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badgeCount != null && badgeCount > 0,
              label: Text('$badgeCount'),
              backgroundColor: AppColors.accentCrimson,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? AppColors.primaryGold
                    : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
                size: 22,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.primaryGold : AppColors.primaryGoldDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
