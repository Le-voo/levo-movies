import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/debounce.dart';
import '../data/models/movie.dart';
import '../data/repositories/movie_repository.dart';
import 'movie_state.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchMoviesNotifier extends StateNotifier<MovieState<List<Movie>>> {
  final MovieRepository _repository;
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 450),
  );
  String _lastExecutedQuery = '';

  SearchMoviesNotifier(this._repository) : super(const MovieInitial());

  void onQueryChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _debouncer.cancel();
      _lastExecutedQuery = '';
      state = const MovieInitial();
      return;
    }

    if (trimmed == _lastExecutedQuery) return;

    state = const MovieLoading();
    _debouncer.run(() {
      _search(trimmed);
    });
  }

  Future<void> _search(String query) async {
    _lastExecutedQuery = query;
    try {
      final results = await _repository.searchMovies(query);
      if (results.isEmpty) {
        state = MovieEmpty('No movies found matching "$query"');
      } else {
        state = MovieLoaded(results);
      }
    } catch (e) {
      state = MovieError(e.toString());
    }
  }

  Future<void> retry() async {
    if (_lastExecutedQuery.isNotEmpty) {
      state = const MovieLoading();
      await _search(_lastExecutedQuery);
    }
  }

  void clear() {
    _debouncer.cancel();
    _lastExecutedQuery = '';
    state = const MovieInitial();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}

final searchMoviesProvider =
    StateNotifierProvider.autoDispose<
      SearchMoviesNotifier,
      MovieState<List<Movie>>
    >((ref) {
      final repository = ref.watch(movieRepositoryProvider);
      return SearchMoviesNotifier(repository);
    });
