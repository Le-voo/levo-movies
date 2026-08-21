import '../../core/constants/api_constants.dart';
import '../../core/utils/formatters.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final double popularity;
  final String? originalLanguage;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
    this.popularity = 0.0,
    this.originalLanguage,
  });

  String get fullPosterUrl => ApiConstants.posterUrl(posterPath);
  String get fullBackdropUrl => ApiConstants.backdropUrl(backdropPath);
  String get formattedReleaseDate => AppFormatters.formatDate(releaseDate);
  String get releaseYear => AppFormatters.formatYear(releaseDate);
  String get formattedRating => AppFormatters.formatRating(voteAverage);

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Untitled',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate:
          json['release_date'] as String? ?? json['first_air_date'] as String?,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      originalLanguage: json['original_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'popularity': popularity,
      'original_language': originalLanguage,
    };
  }

  // SQLite representation for local offline watchlist
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds.join(','),
      'popularity': popularity,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    final genreIdsStr = map['genre_ids'] as String? ?? '';
    final parsedGenreIds = genreIdsStr.isNotEmpty
        ? genreIdsStr
              .split(',')
              .map((e) => int.tryParse(e) ?? 0)
              .where((e) => e != 0)
              .toList()
        : <int>[];

    return Movie(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? 'Untitled',
      overview: map['overview'] as String? ?? '',
      posterPath: map['poster_path'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: map['vote_count'] as int? ?? 0,
      releaseDate: map['release_date'] as String?,
      genreIds: parsedGenreIds,
      popularity: (map['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
