import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie_detail.dart';
import '../data/repositories/movie_repository.dart';
import 'movie_state.dart';

final movieDetailProvider = StateNotifierProvider.family
    .autoDispose<MovieDetailNotifier, MovieState<MovieDetail>, int>((
      ref,
      movieId,
    ) {
      final repository = ref.watch(movieRepositoryProvider);
      return MovieDetailNotifier(repository, movieId);
    });

class MovieDetailNotifier extends StateNotifier<MovieState<MovieDetail>> {
  final MovieRepository _repository;
  final int movieId;

  MovieDetailNotifier(this._repository, this.movieId)
    : super(const MovieInitial()) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = const MovieLoading();
    try {
      final detail = await _repository.getMovieDetails(movieId);
      state = MovieLoaded(detail);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}
