import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../state/movie_state.dart';
import '../../state/trending_provider.dart';
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_movies_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Movie Explorer',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search Movies',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Change Theme',
            icon: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            onPressed: () => ThemeSwitcherSheet.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Search SearchBar Entrypoint
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkSurfaceBorder
                          : AppColors.lightSurfaceBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: theme.textTheme.bodySmall?.color,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search movies, actors, titles...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Horizontal Category Selector Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: TrendingCategory.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = TrendingCategory.values[index];
                  final isSelected = category == selectedCategory;
                  return ChoiceChip(
                    label: Text(category.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(trendingCategoryProvider.notifier).state =
                            category;
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Movies Content with Sealed State Handling
            Expanded(
              child: switch (trendingState) {
                MovieInitial<List<Movie>>() ||
                MovieLoading<List<Movie>>() => const LoadingShimmerGrid(),
                MovieLoaded<List<Movie>>(:final data) => MovieGridView(
                  movies: data,
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
