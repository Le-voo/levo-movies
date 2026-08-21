import '../../core/constants/api_constants.dart';
import '../../core/utils/formatters.dart';
import 'genre.dart';
import 'movie.dart';

class MovieDetail {
  final int id;
  final String title;
  final String? tagline;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final int? runtime;
  final List<Genre> genres;
  final int? budget;
  final int? revenue;
  final String? status;
  final String? homepage;
  final double popularity;
  final String? originalLanguage;

  const MovieDetail({
    required this.id,
    required this.title,
    this.tagline,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.releaseDate,
    this.runtime,
    this.genres = const [],
    this.budget,
    this.revenue,
    this.status,
    this.homepage,
    this.popularity = 0.0,
    this.originalLanguage,
  });

  String get fullPosterUrl => ApiConstants.posterUrl(posterPath);
  String get fullBackdropUrl =>
      ApiConstants.backdropUrl(backdropPath, size: 'original');
  String get formattedReleaseDate => AppFormatters.formatDate(releaseDate);
  String get releaseYear => AppFormatters.formatYear(releaseDate);
  String get formattedRating => AppFormatters.formatRating(voteAverage);
  String get formattedRuntime => AppFormatters.formatRuntime(runtime);
  String get formattedBudget => AppFormatters.formatCurrency(budget);
  String get formattedRevenue => AppFormatters.formatCurrency(revenue);

  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      voteCount: voteCount,
      releaseDate: releaseDate,
      genreIds: genres.map((g) => g.id).toList(),
      popularity: popularity,
      originalLanguage: originalLanguage,
    );
  }

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      tagline: json['tagline'] as String?,
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      status: json['status'] as String?,
      homepage: json['homepage'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      originalLanguage: json['original_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tagline': tagline,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'runtime': runtime,
      'genres': genres.map((g) => g.toJson()).toList(),
      'budget': budget,
      'revenue': revenue,
      'status': status,
      'homepage': homepage,
      'popularity': popularity,
      'original_language': originalLanguage,
    };
  }
}
