import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/infrastructure/movie_repository.dart';

part 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  final MovieRepository _movieRepository;
  int currentPage = 1;
  bool isFetching = false;

  MovieCubit(this._movieRepository) : super(const MovieInitial());

  Future<void> fetchMovies({bool loadMore = false}) async {
    if (loadMore && isFetching) return; // Prevent multiple calls
    try {
      if (!loadMore) {
        emit(const MovieLoading());
      }
      isFetching = true;
      final posters = await _movieRepository.fetchMoviePosters(currentPage);
      if (loadMore) {
        emit(MovieLoaded(state.posters + posters));
      } else {
        emit(MovieLoaded(posters));
      }
      if (!loadMore) {
        currentPage++;
      }
      isFetching = false;
    } catch (e) {
      isFetching = false;
      emit(const MovieError('Failed to fetch movies!'));
    }
  }
}
