import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/theme/app_theme.dart';
import 'package:movie_explorer/core/theme/theme_provider.dart';
import 'package:movie_explorer/data/models/movie.dart';
import 'package:movie_explorer/presentation/screens/main_navigation_screen.dart';
import 'package:movie_explorer/state/movie_state.dart';
import 'package:movie_explorer/state/trending_provider.dart';
import 'package:movie_explorer/state/watchlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTrendingMoviesNotifier extends StateNotifier<MovieState<List<Movie>>>
    implements TrendingMoviesNotifier {
  MockTrendingMoviesNotifier(super.state);

  @override
  Future<void> fetchMovies([TrendingCategory? category]) async {}

  @override
  Future<void> refresh() async {}
}

class MockWatchlistNotifier extends StateNotifier<List<Movie>>
    implements WatchlistNotifier {
  MockWatchlistNotifier(super.state);

  @override
  bool isMovieSaved(int movieId) => state.any((m) => m.id == movieId);

  @override
  Future<void> loadWatchlist() async {}

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    state = state.where((m) => m.id != movieId).toList();
  }

  @override
  Future<bool> toggleWatchlist(Movie movie) async {
    return true;
  }
}

void main() {
  testWidgets('App renders main navigation screen smoke test', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    final testMovies = [
      const Movie(
        id: 1,
        title: 'Interstellar',
        overview: 'A team of explorers travel through a wormhole in space.',
        posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        voteAverage: 8.7,
        releaseDate: '2014-11-05',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          trendingMoviesProvider.overrideWith(
            (ref) => MockTrendingMoviesNotifier(MovieLoaded(testMovies)),
          ),
          watchlistProvider.overrideWith((ref) => MockWatchlistNotifier([])),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const MainNavigationScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify app bar title and navigation destinations
    expect(find.text('Movie Explorer'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Interstellar'), findsOneWidget);
  });
}
