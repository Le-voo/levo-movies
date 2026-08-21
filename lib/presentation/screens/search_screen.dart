import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie.dart';
import '../../state/movie_state.dart';
import '../../state/search_provider.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search movies by title...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchMoviesProvider.notifier).clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (query) {
            setState(() {});
            ref.read(searchMoviesProvider.notifier).onQueryChanged(query);
          },
        ),
        actions: const [SizedBox(width: 12)],
      ),
      body: SafeArea(
        child: switch (searchState) {
          MovieInitial<List<Movie>>() => _buildInitialState(context),
          MovieLoading<List<Movie>>() => _buildLoadingList(),
          MovieLoaded<List<Movie>>(:final data) => _buildResultsList(
            context,
            data,
          ),
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

  Widget _buildInitialState(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Popular Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQueries.map((query) {
              return ActionChip(
                label: Text(query),
                avatar: const Icon(Icons.search_rounded, size: 16),
                onPressed: () {
                  _searchController.text = query;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: query.length),
                  );
                  ref.read(searchMoviesProvider.notifier).onQueryChanged(query);
                  setState(() {});
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.movie_creation_outlined,
                  size: 64,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Search millions of movies on TMDB',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
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
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: const Row(
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
                    ShimmerBox(
                      width: double.infinity,
                      height: 12,
                      borderRadius: 4,
                    ),
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

  Widget _buildResultsList(BuildContext context, List<Movie> movies) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = movies[index];
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
                  // Poster Thumbnail with Hero
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 80,
                      height: 115,
                      child:
                          movie.posterPath != null &&
                              movie.posterPath!.isNotEmpty
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
                  // Metadata
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
                            RatingBadge(
                              rating: movie.voteAverage,
                              isCompact: true,
                            ),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.darkTextMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
