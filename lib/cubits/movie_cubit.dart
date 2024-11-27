import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../infrastructure/movie_service.dart';

part 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  final TMDbService tmdbService;
  int currentPage = 1;
  bool isFetching = false;

  MovieCubit(this.tmdbService) : super(MovieInitial());

  Future<void> fetchMovies({bool loadMore = false}) async {
    if (loadMore && isFetching) return;
    try {
      if (!loadMore) {
        emit(MovieLoading());
      }
      isFetching = true;
      final posters = await tmdbService.fetchMoviePosters(currentPage);
      if (loadMore) {
        emit(MovieLoaded( state.props.map((Object? poster) => poster.toString()).toList() + posters));
      } else {
        emit(MovieLoaded(posters));
      }
      if (!loadMore) {
        currentPage++; // Increment page after the first fetch
      }
      isFetching = false;
    } catch (e) {
      isFetching = false;
      emit(const MovieError('Failed to get posters!'));
    }
  }
}
