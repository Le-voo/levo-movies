import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../state/movie_state.dart';
import '../../state/search_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/rating_badge.dart';
import '../widgets/state_views.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  final List<String> _suggestedQueries = [
    'Inception',
    'Oppenheimer',
    'Interstellar',
    'Avengers',
    'The Dark Knight',
    'Spider-Man',
    'Dune',
    'Gladiator',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // Explicit disposal of text controller and focus node
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchMoviesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GlassContainer(
            blur: 20,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search movies by title...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryGold,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel_rounded, size: 20),
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchMoviesProvider.notifier).clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (query) {
                setState(() {});
                ref.read(searchMoviesProvider.notifier).onQueryChanged(query);
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: switch (searchState) {
          MovieInitial<List<Movie>>() => _buildInitialState(context, isDark),
          MovieLoading<List<Movie>>() => _buildLoadingList(),
          MovieLoaded<List<Movie>>(:final data) => _buildResultsList(context, data, isDark),
          MovieEmpty<List<Movie>>(:final message) => EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'No Movies Found',
              message: message,
            ),
          MovieError<List<Movie>>(:final message) => ErrorStateView(
              message: message,
              onRetry: () => ref.read(searchMoviesProvider.notifier).retry(),
            ),
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Popular Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Glassy, High-Contrast Suggestion Chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestedQueries.map((query) {
              return GlassContainer(
                blur: 16,
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.65)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.85),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                onTap: () {
                  _searchController.text = query;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: query.length),
                  );
                  ref.read(searchMoviesProvider.notifier).onQueryChanged(query);
                  setState(() {});
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      query,
                      style: TextStyle(
                        // High-contrast, crystal-clear typography
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 52),
          Center(
            child: GlassContainer(
              blur: 16,
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: 56,
                    color: AppColors.primaryGold.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Explore Millions of Movies',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Type any movie title, franchise, or actor above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const GlassContainer(
          blur: 12,
          borderRadius: 16,
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ShimmerBox(width: 80, height: 110, borderRadius: 12),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 160, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 80, height: 12, borderRadius: 4),
                    SizedBox(height: 12),
                    ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: 180, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<Movie> movies,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = movies[index];
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
              // Poster Thumbnail with Hero
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
              // Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
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
                        RatingBadge(
                          rating: movie.voteAverage,
                          isCompact: true,
                        ),
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
              const Padding(
                padding: EdgeInsets.only(top: 36, right: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
