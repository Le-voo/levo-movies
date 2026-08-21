import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../data/models/movie_detail.dart';
import '../../state/detail_provider.dart';
import '../../state/movie_state.dart';
import '../../state/watchlist_provider.dart';
import '../widgets/rating_badge.dart';
import '../widgets/state_views.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final int movieId;
  final Movie? initialMovie;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.initialMovie,
  });

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    // Explicit disposal of all controllers to ensure 0 memory leaks
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(movieDetailProvider(widget.movieId));
    final isSaved = ref.watch(isMovieInWatchlistProvider(widget.movieId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use initialMovie for immediate hero transition while full details load
    final title = widget.initialMovie?.title ?? 'Movie Details';
    final posterUrl = widget.initialMovie?.fullPosterUrl;
    final backdropUrl = widget.initialMovie?.fullBackdropUrl;

    return Scaffold(
      body: detailState is MovieError<MovieDetail>
          ? SafeArea(
              child: Stack(
                children: [
                  ErrorStateView(
                    message: detailState.message,
                    onRetry: () => ref
                        .read(movieDetailProvider(widget.movieId).notifier)
                        .fetchDetail(),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Collapsing Sliver App Bar with Backdrop Image
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  stretch: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  foregroundColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.55),
                        child: IconButton(
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isSaved
                                ? AppColors.primaryGold
                                : Colors.white,
                            size: 20,
                          ),
                          onPressed: () => _handleWatchlistToggle(detailState),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Backdrop Image
                        _buildBackdropImage(detailState, backdropUrl),
                        // Gradient Overlay for readability
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  theme.scaffoldBackgroundColor.withValues(
                                    alpha: 0.8,
                                  ),
                                  theme.scaffoldBackgroundColor,
                                ],
                                stops: const [0.0, 0.4, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Details Body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overlapping Poster + Title Header
                        _buildHeader(
                          context,
                          detailState,
                          title,
                          posterUrl,
                          isSaved,
                        ),
                        const SizedBox(height: 24),

                        // Detail Content or Loading Skeleton
                        if (detailState is MovieLoading<MovieDetail>)
                          _buildDetailSkeleton(context)
                        else if (detailState is MovieLoaded<MovieDetail>)
                          _buildLoadedDetails(
                            context,
                            detailState.data,
                            isSaved,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: detailState is MovieLoaded<MovieDetail>
          ? _buildBottomActionBar(context, detailState.data, isSaved)
          : (widget.initialMovie != null
                ? _buildBottomActionBarForMovie(
                    context,
                    widget.initialMovie!,
                    isSaved,
                  )
                : null),
    );
  }

  Widget _buildBackdropImage(
    MovieState<MovieDetail> state,
    String? fallbackUrl,
  ) {
    String? url;
    if (state is MovieLoaded<MovieDetail>) {
      url = state.data.backdropPath != null
          ? state.data.fullBackdropUrl
          : state.data.fullPosterUrl;
    } else {
      url = fallbackUrl;
    }

    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.darkSurfaceVariant,
        child: const Center(
          child: Icon(
            Icons.movie_rounded,
            size: 64,
            color: AppColors.darkTextMuted,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const ShimmerBox(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.darkSurfaceVariant,
        child: const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: AppColors.darkTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    MovieState<MovieDetail> state,
    String title,
    String? posterUrl,
    bool isSaved,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rating = state is MovieLoaded<MovieDetail>
        ? state.data.voteAverage
        : (widget.initialMovie?.voteAverage ?? 0.0);
    final year = state is MovieLoaded<MovieDetail>
        ? state.data.releaseYear
        : (widget.initialMovie?.releaseYear ?? 'TBA');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Overlapping Poster
        Hero(
          tag: 'movie-poster-${widget.movieId}',
          child: Container(
            width: 110,
            height: 165,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: posterUrl != null && posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ShimmerBox(
                      width: 110,
                      height: 165,
                      borderRadius: 16,
                    ),
                    errorWidget: (context, url, error) =>
                        _buildPlaceholderPoster(context),
                  )
                : _buildPlaceholderPoster(context),
          ),
        ),
        const SizedBox(width: 16),
        // Title and Essential Badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state is MovieLoaded<MovieDetail> ? state.data.title : title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RatingBadge(rating: rating, isCompact: true),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkSurfaceBorder
                            : AppColors.lightSurfaceBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      year,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedDetails(
    BuildContext context,
    MovieDetail movie,
    bool isSaved,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tagline
        if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
          Text(
            '"${movie.tagline}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.primaryGold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Quick Facts Badges (Runtime, Status, Release Date)
        Row(
          children: [
            _buildFactBadge(
              context,
              Icons.timer_outlined,
              movie.formattedRuntime,
            ),
            const SizedBox(width: 10),
            if (movie.status != null) ...[
              _buildFactBadge(
                context,
                Icons.info_outline_rounded,
                movie.status!,
              ),
              const SizedBox(width: 10),
            ],
            _buildFactBadge(
              context,
              Icons.calendar_month_outlined,
              movie.formattedReleaseDate,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Genres Chips
        if (movie.genres.isNotEmpty) ...[
          Text(
            'Genres',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genres.map((g) {
              return Chip(
                label: Text(g.name),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Storyline / Overview
        Text(
          'Storyline',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Additional Stats Grid (Budget, Revenue, Vote Count)
        if ((movie.budget != null && movie.budget! > 0) ||
            (movie.revenue != null && movie.revenue! > 0)) ...[
          Text(
            'Box Office & Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkSurfaceBorder
                    : AppColors.lightSurfaceBorder,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(context, 'Budget', movie.formattedBudget),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
                _buildStatColumn(context, 'Revenue', movie.formattedRevenue),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
                _buildStatColumn(
                  context,
                  'Votes',
                  NumberFormat.compact().format(movie.voteCount),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFactBadge(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceBorder
                : AppColors.lightSurfaceBorder,
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSkeleton(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 220, height: 16, borderRadius: 6),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: 40,
                borderRadius: 12,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: 40,
                borderRadius: 12,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: 40,
                borderRadius: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        ShimmerBox(width: 100, height: 20, borderRadius: 6),
        SizedBox(height: 12),
        ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
        SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
        SizedBox(height: 8),
        ShimmerBox(width: 240, height: 14, borderRadius: 4),
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    MovieDetail movie,
    bool isSaved,
  ) {
    return _buildWatchlistButton(
      context: context,
      isSaved: isSaved,
      onPressed: () async {
        final added = await ref
            .read(watchlistProvider.notifier)
            .toggleWatchlist(movie.toMovie());
        if (!context.mounted) return;
        _showWatchlistToast(context, movie.title, added);
      },
    );
  }

  Widget _buildBottomActionBarForMovie(
    BuildContext context,
    Movie movie,
    bool isSaved,
  ) {
    return _buildWatchlistButton(
      context: context,
      isSaved: isSaved,
      onPressed: () async {
        final added = await ref
            .read(watchlistProvider.notifier)
            .toggleWatchlist(movie);
        if (!context.mounted) return;
        _showWatchlistToast(context, movie.title, added);
      },
    );
  }

  Widget _buildWatchlistButton({
    required BuildContext context,
    required bool isSaved,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.darkSurfaceBorder
                  : AppColors.lightSurfaceBorder,
              width: 0.8,
            ),
          ),
        ),
        child: ScaleTransition(
          scale: _fabScaleAnimation,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved
                  ? (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant)
                  : theme.colorScheme.primary,
              foregroundColor: isSaved
                  ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                  : (isDark ? const Color(0xFF1E1B16) : Colors.white),
              side: isSaved
                  ? BorderSide(
                      color: isDark
                          ? AppColors.darkSurfaceBorder
                          : AppColors.lightSurfaceBorder,
                      width: 1.5,
                    )
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: isSaved ? 0 : 4,
            ),
            icon: Icon(
              isSaved
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
              size: 22,
              color: isSaved ? AppColors.primaryGold : null,
            ),
            label: Text(
              isSaved
                  ? 'In Your Watchlist (Tap to Remove)'
                  : 'Add to Watchlist',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  void _handleWatchlistToggle(MovieState<MovieDetail> state) {
    if (state is MovieLoaded<MovieDetail>) {
      ref
          .read(watchlistProvider.notifier)
          .toggleWatchlist(state.data.toMovie())
          .then((added) {
            if (!mounted) return;
            _showWatchlistToast(context, state.data.title, added);
          });
    } else if (widget.initialMovie != null) {
      ref
          .read(watchlistProvider.notifier)
          .toggleWatchlist(widget.initialMovie!)
          .then((added) {
            if (!mounted) return;
            _showWatchlistToast(context, widget.initialMovie!.title, added);
          });
    }
  }

  void _showWatchlistToast(BuildContext context, String title, bool added) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              added
                  ? Icons.check_circle_rounded
                  : Icons.remove_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                added
                    ? 'Added "$title" to Watchlist'
                    : 'Removed from Watchlist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: added
            ? AppColors.success
            : AppColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPlaceholderPoster(BuildContext context) {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(
          Icons.movie_rounded,
          size: 36,
          color: AppColors.darkTextMuted,
        ),
      ),
    );
  }
}
