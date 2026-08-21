import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../state/watchlist_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/rating_badge.dart';
import '../widgets/state_views.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends ConsumerWidget {
  final VoidCallback? onExploreMovies;

  const WatchlistScreen({super.key, this.onExploreMovies});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Watchlist',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        ),
        actions: [
          if (watchlist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: GlassContainer(
                  blur: 16,
                  borderRadius: 14,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  child: Text(
                    '${watchlist.length} ${watchlist.length == 1 ? 'Movie' : 'Movies'}',
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: watchlist.isEmpty
            ? EmptyStateView(
                icon: Icons.bookmark_border_rounded,
                title: 'Your Watchlist is Empty',
                message:
                    'Save your favorite movies to watch later. Saved movies are available even offline!',
                buttonLabel: 'Explore Movies',
                onButtonPressed: onExploreMovies,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 90), // Bottom padding for floating nav
                itemCount: watchlist.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final movie = watchlist[index];
                  return Dismissible(
                    key: Key('watchlist-${movie.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete_sweep_rounded,
                              color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (direction) {
                      ref
                          .read(watchlistProvider.notifier)
                          .removeFromWatchlist(movie.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Removed "${movie.title}" from watchlist'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: AppColors.primaryGold,
                            onPressed: () {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .toggleWatchlist(movie);
                            },
                          ),
                        ),
                      );
                    },
                    child: _buildWatchlistCard(context, ref, movie, isDark),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildWatchlistCard(
    BuildContext context,
    WidgetRef ref,
    Movie movie,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return GlassContainer(
      blur: 16,
      borderRadius: 20,
      padding: const EdgeInsets.all(10),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(
              movieId: movie.id,
              initialMovie: movie,
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 115,
              child: movie.posterPath != null && movie.posterPath!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.fullPosterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(
                        width: 80,
                        height: 115,
                        borderRadius: 12,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        child: const Icon(
                          Icons.movie_rounded,
                          color: AppColors.darkTextMuted,
                        ),
                      ),
                    )
                  : Container(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      child: const Icon(
                        Icons.movie_rounded,
                        color: AppColors.darkTextMuted,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    RatingBadge(rating: movie.voteAverage, isCompact: true),
                    const SizedBox(width: 10),
                    Text(
                      movie.releaseYear,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview.isNotEmpty
                      ? movie.overview
                      : 'No overview available.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            tooltip: 'Remove from Watchlist',
            onPressed: () {
              ref
                  .read(watchlistProvider.notifier)
                  .removeFromWatchlist(movie.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${movie.title}" from watchlist'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.primaryGold,
                    onPressed: () {
                      ref
                          .read(watchlistProvider.notifier)
                          .toggleWatchlist(movie);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
