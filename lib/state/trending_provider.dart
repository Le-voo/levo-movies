import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie.dart';
import '../data/repositories/movie_repository.dart';
import 'movie_state.dart';

enum TrendingCategory {
  today('Trending Today', 'day'),
  thisWeek('Trending This Week', 'week'),
  nowPlaying('Now Playing', 'now_playing'),
  topRated('Top Rated', 'top_rated');

  final String label;
  final String key;
  const TrendingCategory(this.label, this.key);
}

final trendingCategoryProvider = StateProvider<TrendingCategory>((ref) {
  return TrendingCategory.today;
});

class TrendingMoviesNotifier extends StateNotifier<MovieState<List<Movie>>> {
  final MovieRepository _repository;
  final Ref _ref;

  TrendingMoviesNotifier(this._repository, this._ref)
    : super(const MovieInitial()) {
    // Listen to category changes and re-fetch automatically
    _ref.listen<TrendingCategory>(trendingCategoryProvider, (previous, next) {
      if (previous != next) {
        fetchMovies(next);
      }
    });
  }

  Future<void> fetchMovies([TrendingCategory? category]) async {
    final TrendingCategory currentCategory =
        category ?? _ref.read(trendingCategoryProvider);
    state = const MovieLoading();

    try {
      List<Movie> movies;
      switch (currentCategory) {
        case TrendingCategory.today:
          movies = await _repository.getTrendingMovies(timeWindow: 'day');
          break;
        case TrendingCategory.thisWeek:
          movies = await _repository.getTrendingMovies(timeWindow: 'week');
          break;
        case TrendingCategory.nowPlaying:
          movies = await _repository.getNowPlayingMovies();
          break;
        case TrendingCategory.topRated:
          movies = await _repository.getTopRatedMovies();
          break;
      }

      if (movies.isEmpty) {
        state = const MovieEmpty('No movies found for this category');
      } else {
        state = MovieLoaded(movies);
      }
    } catch (e) {
      state = MovieError(e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchMovies();
  }
}

final trendingMoviesProvider =
    StateNotifierProvider<TrendingMoviesNotifier, MovieState<List<Movie>>>((
      ref,
    ) {
      final repository = ref.watch(movieRepositoryProvider);
      final notifier = TrendingMoviesNotifier(repository, ref);
      // Initial fetch
      notifier.fetchMovies();
      return notifier;
    });
