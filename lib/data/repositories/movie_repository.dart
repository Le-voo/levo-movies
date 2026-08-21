import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MovieRepository(apiClient);
});

class MovieRepository {
  final ApiClient _apiClient;
  List<Genre>? _cachedGenres;

  MovieRepository(this._apiClient);

  Future<List<Movie>> getTrendingMovies({String timeWindow = 'day'}) async {
    final endpoint = timeWindow == 'week'
        ? ApiConstants.trendingWeek
        : ApiConstants.trendingDay;

    final response = await _apiClient.get(endpoint);
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.nowPlaying,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.topRated,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final response = await _apiClient.get(
      ApiConstants.searchMovie,
      queryParameters: {
        'query': query.trim(),
        'page': page,
        'include_adult': false,
      },
    );
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MovieDetail> getMovieDetails(int movieId) async {
    final response = await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId',
    );
    return MovieDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Genre>> getGenres() async {
    if (_cachedGenres != null) return _cachedGenres!;
    final response = await _apiClient.get(ApiConstants.genres);
    final genresList = response.data['genres'] as List<dynamic>? ?? [];
    _cachedGenres = genresList
        .map((e) => Genre.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedGenres!;
  }
}
