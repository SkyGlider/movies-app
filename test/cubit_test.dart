import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/cubits/movie_cubit.dart';
import 'package:movies/infrastructure/movie_repository.dart';

import 'cubit_test.mocks.dart';


@GenerateMocks([MovieRepository])
void main() {
  late MovieCubit movieCubit;
  late MovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    movieCubit = MovieCubit(mockMovieRepository);
  });

  group('MovieCubit', () {
    test('test initial state', () {
      expect(movieCubit.state, equals(const MovieInitial()));
    });

    test('test MovieLoading and MovieLoaded after fetchMovies', () async {
      final posters = ['https://image.tmdb.org/t/p/w500/sample1.jpg'];
      when(mockMovieRepository.fetchMoviePosters(1)).thenAnswer((_) async => posters);

      final expected = [
        const MovieLoading(),
        MovieLoaded(posters),
      ];

      expectLater(movieCubit.stream, emitsInOrder(expected));

      movieCubit.fetchMovies();
    });

    test('test MovieError when fetchMovies throws error', () async {
      when(mockMovieRepository.fetchMoviePosters(1)).thenThrow(Exception('Failed to fetch movies!'));

      final expected = [
        const MovieLoading(),
        const MovieError('Failed to fetch movies!'),
      ];

      expectLater(movieCubit.stream, emitsInOrder(expected));

      movieCubit.fetchMovies();
    });

    test('test infinite scroll', () async {
      final posters1 = ['https://image.tmdb.org/t/p/w500/sample1.jpg'];
      final posters2 = ['https://image.tmdb.org/t/p/w500/sample2.jpg'];
      when(mockMovieRepository.fetchMoviePosters(1)).thenAnswer((_) async => posters1);
      when(mockMovieRepository.fetchMoviePosters(2)).thenAnswer((_) async => posters2);

      expectLater(
        movieCubit.stream,
        emitsInOrder([
          const MovieLoading(),
          MovieLoaded(posters1),
        ]),
      );
      movieCubit.fetchMovies(); // Fetch page 1

      await Future.delayed(const Duration(seconds: 1)); // Wait for the first response
      expectLater(
        movieCubit.stream,
        emitsInOrder([
          MovieLoaded([...posters1, ...posters2]),
        ]),
      );
      movieCubit.fetchMovies(loadMore: true); // Fetch page 2

    });
  });
}