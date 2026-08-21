import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../data/models/movie.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  static const String tableWatchlist = 'watchlist';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movie_explorer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Enable FFI for desktop (Windows, macOS, Linux)
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final docDir = await getApplicationSupportDirectory();
      dbPath = p.join(docDir.path, filePath);
    } else {
      final defaultPath = await getDatabasesPath();
      dbPath = p.join(defaultPath, filePath);
    }

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableWatchlist (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT,
        poster_path TEXT,
        backdrop_path TEXT,
        vote_average REAL,
        vote_count INTEGER,
        release_date TEXT,
        genre_ids TEXT,
        popularity REAL,
        added_at INTEGER
      )
    ''');
  }

  Future<int> insertToWatchlist(Movie movie) async {
    final db = await instance.database;
    return await db.insert(
      tableWatchlist,
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFromWatchlist(int movieId) async {
    final db = await instance.database;
    return await db.delete(
      tableWatchlist,
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  Future<bool> isMovieInWatchlist(int movieId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableWatchlist,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [movieId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<Movie>> getWatchlist() async {
    final db = await instance.database;
    final result = await db.query(tableWatchlist, orderBy: 'added_at DESC');
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
