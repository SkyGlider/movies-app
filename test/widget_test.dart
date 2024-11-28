import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies/cubits/movie_cubit.dart';
import 'package:movies/infrastructure/movie_repository.dart';
import 'package:movies/main.dart';

import 'cubit_test.mocks.dart';

@GenerateMocks([MovieRepository])
void main() {
  late MovieCubit movieCubit;
  late MovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    movieCubit = MovieCubit(mockRepository);
  });

  tearDown(() {
    movieCubit.close();
  });

  testWidgets('Test the loading state and eventually the loaded state',
      (WidgetTester tester) async {
    final posters = [
      'https://image.tmdb.org/t/p/w500/sample1.jpg',
      'https://image.tmdb.org/t/p/w500/sample2.jpg'
    ];

    when(mockRepository.fetchMoviePosters(1)).thenAnswer((_) async => posters);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => movieCubit,
          child: MovieListScreen(),
        ),
      ),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsAtLeast(3));

    // Fetching the movies
    movieCubit.fetchMovies();

    // Wait for the MovieLoaded state
    await tester.pumpAndSettle();

    // Verify posters are displayed in the grid
    expect(find.byType(CachedNetworkImage), findsNWidgets(2));

    // Verify that the loading indicator is gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Test error state',
      (WidgetTester tester) async {
    when(mockRepository.fetchMoviePosters(1))
        .thenThrow(Exception('Failed to fetch movies!'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => movieCubit,
          child: MovieListScreen(),
        ),
      ),
    );

    // Simulate fetching the movies
    movieCubit.fetchMovies();

    // Wait for the MovieError state
    await tester.pumpAndSettle();

    // Verify error message is displayed
    expect(find.text('Failed to fetch movies!'), findsOneWidget);

    // Verify that the loading indicator is gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
