# 🎬 Movie Explorer — Production Flutter Application

A modern, production-grade 3-screen (+ offline Watchlist) movie exploration app built with **Flutter 3.41+**, **Dart 3.11+**, **Riverpod**, and the **TMDB (The Movie Database) API**.

---

## 🌟 Key Features

- 🍿 **Trending & Discovery**: Browse trending movies (Today, This Week), top rated titles, and now playing in cinemas with a responsive `GridView.builder` poster layout.
- 🔍 **Debounced Live Search**: Search millions of movies with a 450ms debounce mechanism, search suggestions, and a dynamic `ListView.builder` result set.
- 📖 **Cinematic Movie Details**: Collapsing `SliverAppBar` with high-resolution backdrop, overlapping poster hero animation, genre tags, storyline overview, ratings badge, runtime, and box-office stats.
- 💾 **100% Offline Watchlist (SQLite)**: Save and manage movies locally using **sqflite** database. Saved movies remain accessible even without an active internet connection.
- 🎨 **Material 3 Cinematic Theming**: Custom deep slate/midnight color scheme with rich amber/gold accents. Live switching between **Dark**, **Light**, and **System** themes with persistent preferences.
- 🛡️ **Sealed State Architecture**: Explicit UI state handling using Dart 3 sealed class `MovieState<T>` (`Initial`, `Loading`, `Loaded`, `Empty`, `Error`) with actionable retry states.
- 📱 **Notch & Dynamic Island Ready**: Strict `SafeArea` wrapping and `MediaQuery.padding` awareness.
- 🧹 **Zero Memory Leaks**: Explicit initialization and lifecycle disposal of all `AnimationController`, `ScrollController`, `TextEditingController`, and focus nodes.

---

## 🏗️ Architecture & State Management

### Why Riverpod?
We chose **`flutter_riverpod`** (v2.6+) for state management across the entire application for several key reasons:

1. **Compile-Time Safety & Zero `BuildContext` Dependence**: Unlike standard `Provider`, Riverpod does not depend on the Flutter widget tree to resolve dependencies, eliminating runtime `ProviderNotFoundException` errors.
2. **First-Class Testability**: Providers can be overridden cleanly in unit and widget tests without spinning up artificial widget trees.
3. **Optimistic UI Updates & Cross-Screen Reactivity**: Adding a movie to the Watchlist from the Detail screen instantly and reactively reflects on the Home badges and Watchlist screen without manual refresh calls.
4. **Auto-Disposing & Memory Optimization**: Utilizing `.autoDispose` ensures search controllers and detail states are garbage-collected as soon as users navigate away.

### Local Persistence: Why SQLite (`sqflite`)?
We chose **`sqflite`** (with desktop FFI compatibility) over simple key-value storage (`shared_preferences`) because:
- Watchlist items represent structured relational entities (movie ID, title, overview, poster path, release date, rating, timestamps).
- Enables indexed queries, ordered sorting (`ORDER BY added_at DESC`), and conflict-safe inserts (`ConflictAlgorithm.replace`).
- Provides scalable offline storage without bloating memory.

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # TMDB endpoints and image sizing URLs
│   │   └── app_colors.dart          # Cinematic dark & light palette
│   ├── database/
│   │   └── app_database.dart        # SQLite initialization and Watchlist CRUD
│   ├── network/
│   │   ├── api_client.dart          # Dio client with auth interceptors
│   │   └── api_exceptions.dart      # Normalized, user-friendly exception mapping
│   ├── theme/
│   │   ├── app_theme.dart           # Material 3 ThemeData with Google Fonts
│   │   └── theme_provider.dart      # Riverpod ThemeMode notifier with persistence
│   └── utils/
│       ├── debounce.dart            # Memory-safe timer debouncer
│       └── formatters.dart          # Currency, runtime, rating, and date formatting
├── data/
│   ├── models/
│   │   ├── genre.dart               # Genre model
│   │   ├── movie.dart               # Movie entity with JSON & SQLite mapping
│   │   └── movie_detail.dart        # Extended movie detail model
│   └── repositories/
│       ├── movie_repository.dart    # TMDB remote data layer
│       └── watchlist_repository.dart# Local offline watchlist data layer
├── state/
│   ├── movie_state.dart             # Sealed UI state union
│   ├── trending_provider.dart       # Trending categories state
│   ├── search_provider.dart         # Debounced search state
│   ├── detail_provider.dart         # Movie detail family provider
│   └── watchlist_provider.dart      # Reactive SQLite watchlist state
├── presentation/
│   ├── screens/
│   │   ├── main_navigation_screen.dart # Bottom Navigation bar container
│   │   ├── home_screen.dart            # Trending grid with category filters
│   │   ├── search_screen.dart          # Search bar with suggestions & results
│   │   ├── movie_detail_screen.dart    # Collapsing backdrop detail view
│   │   └── watchlist_screen.dart       # Offline saved movies with swipe-to-delete
│   └── widgets/
│       ├── movie_card.dart          # Poster card with hero & shimmer
│       ├── movie_grid_view.dart     # Responsive GridView.builder
│       ├── rating_badge.dart        # Color-coded circular/pill score badge
│       ├── state_views.dart         # Shimmer grid, Empty view, and Error view
│       └── theme_switcher_sheet.dart# Bottom sheet theme selector
└── main.dart                        # App entry point & initialization
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Flutter SDK**: `^3.32.0` or higher
- **Dart SDK**: `^3.8.0` or higher
- TMDB API Key (Free from [developer.themoviedb.org](https://developer.themoviedb.org))

### 2. Clone the Repository
```bash
git clone https://github.com/Le-voo/levo-movies.git
cd levo-movies
```

### 3. Configure TMDB API Key
1. Duplicate `.env.example` and name it `.env`:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and insert your TMDB API credentials:
   ```env
   TMDB_API_KEY=your_tmdb_v3_api_key_here
   TMDB_ACCESS_TOKEN=your_tmdb_v4_read_access_token_here
   ```
   *(Note: The app accepts either the v3 `TMDB_API_KEY` or v4 `TMDB_ACCESS_TOKEN`).*

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the Application
```bash
# Run on connected device, emulator, or desktop
flutter run
```

### 6. Run Static Analysis & Tests
```bash
# Run analyzer (0 warnings)
flutter analyze

# Run unit and widget test suite
flutter test
```

---

## 🧪 Testing

The codebase includes automated unit and widget smoke tests in `test/`:
- `test/unit_test.dart`: Validates JSON and SQLite serialization for `Movie`, `MovieDetail`, `Genre`, formatters, and sealed state transitions.
- `test/widget_test.dart`: Validates smoke rendering of `MainNavigationScreen`, custom themes, and Riverpod provider mocking.

---

## 📄 License
MIT License. Created for the TMDB Movie Explorer challenge.
