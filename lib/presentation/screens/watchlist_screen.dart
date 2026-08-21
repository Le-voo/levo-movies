import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../state/watchlist_provider.dart';
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
        title: Text(
          'My Watchlist',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (watchlist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${watchlist.length} ${watchlist.length == 1 ? 'Movie' : 'Movies'}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.all(16),
                itemCount: watchlist.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
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
                          content: Text(
                            'Removed "${movie.title}" from watchlist',
                          ),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: isDark ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppColors.darkSurfaceBorder
              : AppColors.lightSurfaceBorder,
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  MovieDetailScreen(movieId: movie.id, initialMovie: movie),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 115,
                  child:
                      movie.posterPath != null && movie.posterPath!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.fullPosterUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerBox(
                            width: 80,
                            height: 115,
                            borderRadius: 10,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
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
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
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
        ),
      ),
    );
  }
}
