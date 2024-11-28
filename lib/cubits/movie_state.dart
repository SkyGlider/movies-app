part of 'movie_cubit.dart';

abstract class MovieState extends Equatable {
  final List<String> posters;
  final String errorMessage;
  const MovieState(this.posters, this.errorMessage);

  @override
  List<Object?> get props => [posters, errorMessage];
}

class MovieInitial extends MovieState {
  const MovieInitial() : super(const [], '');
}

class MovieLoading extends MovieState {
  const MovieLoading() : super(const [], '');
}

class MovieLoaded extends MovieState {
  const MovieLoaded(List<String> posters) : super(posters, '');
}

class MovieError extends MovieState {
  const MovieError(String errorMessage) : super(const [], errorMessage);
}
