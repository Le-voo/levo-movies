import 'package:flutter/material.dart';
import '../../data/models/movie.dart';
import '../screens/movie_detail_screen.dart';
import 'movie_card.dart';

class MovieGridView extends StatelessWidget {
  final List<Movie> movies;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onRefresh;

  const MovieGridView({
    super.key,
    required this.movies,
    this.physics,
    this.padding,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // Responsive columns: 2 on mobile, 3 on larger screens, 4 on desktop
        int crossAxisCount = 2;
        if (screenWidth >= 900) {
          crossAxisCount = 4;
        } else if (screenWidth >= 600) {
          crossAxisCount = 3;
        }

        final grid = GridView.builder(
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          padding: padding ?? const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return MovieCard(
              movie: movie,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(
                      movieId: movie.id,
                      initialMovie: movie,
                    ),
                  ),
                );
              },
            );
          },
        );

        if (onRefresh != null) {
          return RefreshIndicator(
            onRefresh: () async => onRefresh!(),
            child: grid,
          );
        }

        return grid;
      },
    );
  }
}
