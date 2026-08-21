import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import 'glass_container.dart';
import 'rating_badge.dart';
import 'state_views.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final bool showRatingBadge;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.showRatingBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      blur: 16,
      borderRadius: 20,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'movie-poster-${movie.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                    child: movie.posterPath != null && movie.posterPath!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movie.fullPosterUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const ShimmerBox(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 0,
                            ),
                            errorWidget: (context, url, error) =>
                                _buildPlaceholderPoster(context),
                          )
                        : _buildPlaceholderPoster(context),
                  ),
                ),
                // Subtle bottom gradient for image edge
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Rating Badge (Top Right)
                if (showRatingBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RatingBadge(
                      rating: movie.voteAverage,
                      isCompact: true,
                    ),
                  ),
              ],
            ),
          ),
          // Movie Title & Metadata
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.releaseYear,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPoster(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_rounded,
              size: 40,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Poster',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
