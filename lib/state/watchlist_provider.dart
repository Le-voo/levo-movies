import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie.dart';
import '../data/repositories/watchlist_repository.dart';

class WatchlistNotifier extends StateNotifier<List<Movie>> {
  final WatchlistRepository _repository;

  WatchlistNotifier(this._repository) : super([]) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    try {
      final list = await _repository.getWatchlist();
      state = list;
    } catch (_) {
      state = [];
    }
  }

  bool isMovieSaved(int movieId) {
    return state.any((movie) => movie.id == movieId);
  }

  Future<bool> toggleWatchlist(Movie movie) async {
    final alreadySaved = isMovieSaved(movie.id);
    if (alreadySaved) {
      // Optimistic update
      state = state.where((m) => m.id != movie.id).toList();
      await _repository.removeFromWatchlist(movie.id);
      return false; // Removed
    } else {
      // Optimistic update
      state = [movie, ...state];
      await _repository.addToWatchlist(movie);
      return true; // Added
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    state = state.where((m) => m.id != movieId).toList();
    await _repository.removeFromWatchlist(movieId);
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<Movie>>(
  (ref) {
    final repository = ref.watch(watchlistRepositoryProvider);
    return WatchlistNotifier(repository);
  },
);

final isMovieInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.any((m) => m.id == movieId);
});
