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
import '../widgets/glass_container.dart';
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
                  expandedHeight: 340,
                  pinned: true,
                  stretch: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  foregroundColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassContainer(
                      blur: 20,
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GlassContainer(
                        blur: 20,
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.45),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color:
                                isSaved ? AppColors.primaryGold : Colors.white,
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
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                  theme.scaffoldBackgroundColor
                                      .withValues(alpha: 0.85),
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
                            context, detailState, title, posterUrl, isSaved),
                        const SizedBox(height: 24),

                        // Detail Content or Loading Skeleton
                        if (detailState is MovieLoading<MovieDetail>)
                          _buildDetailSkeleton(context)
                        else if (detailState is MovieLoaded<MovieDetail>)
                          _buildLoadedDetails(
                              context, detailState.data, isSaved),
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
                  context, widget.initialMovie!, isSaved)
              : null),
    );
  }

  Widget _buildBackdropImage(
      MovieState<MovieDetail> state, String? fallbackUrl) {
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
          child:
              Icon(Icons.movie_rounded, size: 64, color: AppColors.darkTextMuted),
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
          child: Icon(Icons.broken_image_rounded,
              size: 48, color: AppColors.darkTextMuted),
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
        // Overlapping Glassy Poster Card
        Hero(
          tag: 'movie-poster-${widget.movieId}',
          child: Container(
            width: 115,
            height: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: posterUrl != null && posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ShimmerBox(
                      width: 115,
                      height: 172,
                      borderRadius: 20,
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
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RatingBadge(rating: rating, isCompact: true),
                  GlassContainer(
                    blur: 16,
                    borderRadius: 12,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      year,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF0F172A),
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
    final isDark = theme.brightness == Brightness.dark;

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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
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
        const SizedBox(height: 22),

        // Genres Chips
        if (movie.genres.isNotEmpty) ...[
          Text(
            'Genres',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genres.map((g) {
              return GlassContainer(
                blur: 16,
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.8),
                child: Text(
                  g.name,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF0F172A),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Storyline / Overview
        Text(
          'Storyline',
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        GlassContainer(
          blur: 16,
          borderRadius: 20,
          padding: const EdgeInsets.all(18),
          child: Text(
            movie.overview.isNotEmpty
                ? movie.overview
                : 'No overview available.',
            style: TextStyle(
              height: 1.6,
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Box Office & Stats
        if ((movie.budget != null && movie.budget! > 0) ||
            (movie.revenue != null && movie.revenue! > 0)) ...[
          Text(
            'Box Office & Stats',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            blur: 20,
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
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
    return Expanded(
      child: GlassContainer(
        blur: 16,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGold),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.primaryGold,
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
        final added =
            await ref.read(watchlistProvider.notifier).toggleWatchlist(movie);
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: ScaleTransition(
          scale: _fabScaleAnimation,
          child: GlassContainer(
            blur: 24,
            borderRadius: 24,
            padding: EdgeInsets.zero,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaved
                    ? (isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.8))
                    : AppColors.primaryGold,
                foregroundColor: isSaved
                    ? (isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF0F172A))
                    : const Color(0xFF1E1B16),
                side: isSaved
                    ? BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : const Color(0xFFCBD5E1),
                        width: 1.2,
                      )
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: isSaved ? 0 : 6,
                shadowColor: AppColors.primaryGold.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: Icon(
                isSaved
                    ? Icons.bookmark_added_rounded
                    : Icons.bookmark_add_outlined,
                size: 22,
                color: isSaved ? AppColors.primaryGold : null,
              ),
              label: Text(
                isSaved ? 'In Your Watchlist (Tap to Remove)' : 'Add to Watchlist',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
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
        backgroundColor:
            added ? AppColors.success : AppColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
