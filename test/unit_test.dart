import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/utils/formatters.dart';
import 'package:movie_explorer/data/models/genre.dart';
import 'package:movie_explorer/data/models/movie.dart';
import 'package:movie_explorer/data/models/movie_detail.dart';
import 'package:movie_explorer/state/movie_state.dart';

void main() {
  group('Data Models & Serialization', () {
    test('Movie fromJson parses valid data correctly', () {
      final json = {
        'id': 550,
        'title': 'Fight Club',
        'overview': 'An insomniac office worker...',
        'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
        'vote_average': 8.433,
        'vote_count': 26000,
        'release_date': '1999-10-15',
        'genre_ids': [18, 53],
        'popularity': 61.416,
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.voteAverage, 8.433);
      expect(movie.releaseYear, '1999');
      expect(movie.formattedRating, '8.4');
      expect(movie.genreIds, [18, 53]);
    });

    test('Genre fromJson and toJson work correctly', () {
      final json = {'id': 28, 'name': 'Action'};
      final genre = Genre.fromJson(json);
      expect(genre.id, 28);
      expect(genre.name, 'Action');
      expect(genre.toJson(), json);
    });

    test('Movie SQLite toMap and fromMap preserve data correctly', () {
      const movie = Movie(
        id: 101,
        title: 'Inception',
        overview: 'A thief who steals corporate secrets...',
        posterPath: '/path.jpg',
        voteAverage: 8.8,
        voteCount: 34000,
        releaseDate: '2010-07-16',
        genreIds: [28, 878],
      );

      final map = movie.toMap();
      final restored = Movie.fromMap(map);

      expect(restored.id, movie.id);
      expect(restored.title, movie.title);
      expect(restored.voteAverage, movie.voteAverage);
      expect(restored.genreIds, movie.genreIds);
    });

    test('MovieDetail parses extended properties correctly', () {
      final json = {
        'id': 550,
        'title': 'Fight Club',
        'tagline': 'Mischief. Mayhem. Soap.',
        'overview': 'An insomniac office worker...',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 8.4,
        'vote_count': 26000,
        'release_date': '1999-10-15',
        'runtime': 139,
        'budget': 63000000,
        'revenue': 100853753,
        'status': 'Released',
        'genres': [
          {'id': 18, 'name': 'Drama'},
          {'id': 53, 'name': 'Thriller'},
        ],
      };

      final detail = MovieDetail.fromJson(json);

      expect(detail.tagline, 'Mischief. Mayhem. Soap.');
      expect(detail.formattedRuntime, '2h 19m');
      expect(detail.formattedBudget, '\$63.0M');
      expect(detail.formattedRevenue, '\$100.9M');
      expect(detail.genres.length, 2);
      expect(detail.genres.first.name, 'Drama');
    });
  });

  group('AppFormatters', () {
    test('formatDate parses ISO strings to readable format', () {
      expect(AppFormatters.formatDate('2023-07-21'), 'Jul 21, 2023');
      expect(AppFormatters.formatDate(null), 'TBA');
    });

    test('formatCurrency converts amounts cleanly', () {
      expect(AppFormatters.formatCurrency(150000000), '\$150.0M');
      expect(AppFormatters.formatCurrency(1200000000), '\$1.2B');
      expect(AppFormatters.formatCurrency(0), 'N/A');
    });

    test('formatRuntime handles various durations', () {
      expect(AppFormatters.formatRuntime(120), '2h');
      expect(AppFormatters.formatRuntime(95), '1h 35m');
      expect(AppFormatters.formatRuntime(45), '45m');
      expect(AppFormatters.formatRuntime(null), 'Unknown');
    });
  });

  group('MovieState Sealed Class', () {
    test('State sub-classes instantiate correctly', () {
      const initial = MovieInitial<List<Movie>>();
      const loading = MovieLoading<List<Movie>>();
      const empty = MovieEmpty<List<Movie>>('No movies');
      const loaded = MovieLoaded<String>('Success');
      const error = MovieError<String>('Network error');

      expect(initial, isA<MovieState<List<Movie>>>());
      expect(loading, isA<MovieState<List<Movie>>>());
      expect(empty.message, 'No movies');
      expect(loaded.data, 'Success');
      expect(error.message, 'Network error');
    });
  });
}
