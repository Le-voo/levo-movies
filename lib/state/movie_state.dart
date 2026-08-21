sealed class MovieState<T> {
  const MovieState();
}

class MovieInitial<T> extends MovieState<T> {
  const MovieInitial();
}

class MovieLoading<T> extends MovieState<T> {
  const MovieLoading();
}

class MovieLoaded<T> extends MovieState<T> {
  final T data;
  const MovieLoaded(this.data);
}

class MovieEmpty<T> extends MovieState<T> {
  final String message;
  const MovieEmpty([this.message = 'No movies found']);
}

class MovieError<T> extends MovieState<T> {
  final String message;
  const MovieError(this.message);
}
