import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../models/movie.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WatchlistRepository(db);
});

class WatchlistRepository {
  final AppDatabase _database;

  WatchlistRepository(this._database);

  Future<List<Movie>> getWatchlist() async {
    return await _database.getWatchlist();
  }

  Future<bool> isMovieInWatchlist(int movieId) async {
    return await _database.isMovieInWatchlist(movieId);
  }

  Future<void> addToWatchlist(Movie movie) async {
    await _database.insertToWatchlist(movie);
  }

  Future<void> removeFromWatchlist(int movieId) async {
    await _database.removeFromWatchlist(movieId);
  }
}
