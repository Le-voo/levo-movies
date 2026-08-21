import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../state/movie_state.dart';
import '../../state/trending_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/movie_grid_view.dart';
import '../widgets/state_views.dart';
import '../widgets/theme_switcher_sheet.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingState = ref.watch(trendingMoviesProvider);
    final selectedCategory = ref.watch(trendingCategoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_movies_rounded,
                color: Color(0xFF1E1B16),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Movie Explorer',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                fontSize: 21,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GlassContainer(
              blur: 16,
              shape: BoxShape.circle,
              padding: const EdgeInsets.all(4),
              child: IconButton(
                tooltip: 'Search Movies',
                icon: const Icon(Icons.search_rounded, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: GlassContainer(
              blur: 16,
              shape: BoxShape.circle,
              padding: const EdgeInsets.all(4),
              child: IconButton(
                tooltip: 'Change Theme',
                icon: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
                onPressed: () => ThemeSwitcherSheet.show(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frosted Glass Search Bar Trigger
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: GlassContainer(
                blur: 20,
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Search movies, franchises, genres...',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Glass Category Selector Pills
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: TrendingCategory.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = TrendingCategory.values[index];
                  final isSelected = category == selectedCategory;

                  return GlassContainer(
                    blur: 16,
                    borderRadius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isSelected
                        ? AppColors.primaryGold.withValues(alpha: isDark ? 0.3 : 0.22)
                        : (isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.6)),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.8)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    onTap: () {
                      ref.read(trendingCategoryProvider.notifier).state = category;
                    },
                    child: Center(
                      child: Text(
                        category.label,
                        style: TextStyle(
                          color: isSelected
                              ? (isDark ? AppColors.primaryGold : AppColors.primaryGoldDark)
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF334155)),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Movies Content with Sealed State Handling
            Expanded(
              child: switch (trendingState) {
                MovieInitial<List<Movie>>() ||
                MovieLoading<List<Movie>>() =>
                  const LoadingShimmerGrid(),
                MovieLoaded<List<Movie>>(:final data) => MovieGridView(
                    movies: data,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90), // Bottom padding for floating nav
                    onRefresh: () =>
                        ref.read(trendingMoviesProvider.notifier).refresh(),
                  ),
                MovieEmpty<List<Movie>>(:final message) => EmptyStateView(
                    title: 'No Movies Found',
                    message: message,
                    buttonLabel: 'Refresh',
                    onButtonPressed: () =>
                        ref.read(trendingMoviesProvider.notifier).refresh(),
                  ),
                MovieError<List<Movie>>(:final message) => ErrorStateView(
                    message: message,
                    onRetry: () =>
                        ref.read(trendingMoviesProvider.notifier).refresh(),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
