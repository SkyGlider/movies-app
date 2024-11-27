import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/cubits/movie_cubit.dart';
import 'package:movies/infrastructure/movie_service.dart';


@GenerateMocks([TMDbService])
void main() {
  late MovieCubit movieCubit;
  late TMDbService mockTMDbService;

  setUp(() {
    mockTMDbService = TMDbService();
    movieCubit = MovieCubit(mockTMDbService);
  });

  group('MovieCubit', () {
    test('test initial state', () {
      expect(movieCubit.state, equals(MovieInitial()));
    });

    test('test MovieLoading and MovieLoaded after fetchMovies', () async {
      final posters = ['https://image.tmdb.org/t/p/w500/sample1.jpg'];
      when(mockTMDbService.fetchMoviePosters(1)).thenAnswer((_) async => posters);

      final expected = [
        MovieLoading(),
        MovieLoaded(posters),
      ];

      expectLater(movieCubit.stream, emitsInOrder(expected));

      movieCubit.fetchMovies();
    });

    test('test MovieError when fetchMovies throws error', () async {
      when(mockTMDbService.fetchMoviePosters(1)).thenThrow(Exception('Failed to load movies'));

      final expected = [
        MovieLoading(),
        const MovieError('Failed to load movies'),
      ];

      expectLater(movieCubit.stream, emitsInOrder(expected));

      movieCubit.fetchMovies();
    });

    test('test infinite scroll', () async {
      final posters1 = ['https://image.tmdb.org/t/p/w500/sample1.jpg'];
      final posters2 = ['https://image.tmdb.org/t/p/w500/sample2.jpg'];
      when(mockTMDbService.fetchMoviePosters(1)).thenAnswer((_) async => posters1);
      when(mockTMDbService.fetchMoviePosters(2)).thenAnswer((_) async => posters2);

      movieCubit.fetchMovies(); // Fetch page 1
      expectLater(
        movieCubit.stream,
        emitsInOrder([
          MovieLoading(),
          MovieLoaded(posters1),
        ]),
      );

      await Future.delayed(const Duration(seconds: 1)); // Wait for the first response

      movieCubit.fetchMovies(loadMore: true); // Fetch page 2
      expectLater(
        movieCubit.stream,
        emitsInOrder([
          MovieLoaded([...posters1, ...posters2]),
        ]),
      );
    });
  });
}