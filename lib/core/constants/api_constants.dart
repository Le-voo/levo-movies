class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrlW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlOriginal =
      'https://image.tmdb.org/t/p/original';
  static const String imageBaseUrlW780 = 'https://image.tmdb.org/t/p/w780';
  static const String imageBaseUrlW342 = 'https://image.tmdb.org/t/p/w342';

  // Endpoints
  static const String trendingDay = '/trending/movie/day';
  static const String trendingWeek = '/trending/movie/week';
  static const String nowPlaying = '/movie/now_playing';
  static const String topRated = '/movie/top_rated';
  static const String popular = '/movie/popular';
  static const String searchMovie = '/search/movie';
  static const String movieDetails = '/movie';
  static const String genres = '/genre/movie/list';

  static String posterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  static String backdropUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }
}
