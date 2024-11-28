import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies/cubits/movie_cubit.dart';
import 'package:movies/infrastructure/movie_service.dart';
import 'package:movies/main.dart';


@GenerateMocks([TMDbService])
void main() {
  late MovieCubit movieCubit;
  late TMDbService mockTMDbService;

  setUp(() {
    mockTMDbService = TMDbService();
    movieCubit = MovieCubit(mockTMDbService);
  });

  testWidgets('Movie posters grid shows loading and then posters', (WidgetTester tester) async {
    final posters = ['https://image.tmdb.org/t/p/w500/sample1.jpg', 'https://image.tmdb.org/t/p/w500/sample2.jpg'];

    when(mockTMDbService.fetchMoviePosters(1)).thenAnswer((_) async => posters);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => movieCubit,
          child: MovieListScreen(),
        ),
      ),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Simulate fetching the movies
    movieCubit.fetchMovies();

    // Wait for the MovieLoaded state
    await tester.pumpAndSettle();

    // Verify posters are displayed in the grid
    expect(find.byType(CachedNetworkImage), findsNWidgets(2));

    // Verify that the loading indicator is gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Movie posters grid shows error message when fetching fails', (WidgetTester tester) async {
    when(mockTMDbService.fetchMoviePosters(1)).thenThrow(Exception('Failed to load movies'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => movieCubit,
          child: MovieListScreen(),
        ),
      ),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Simulate fetching the movies
    movieCubit.fetchMovies();

    // Wait for the MovieError state
    await tester.pumpAndSettle();

    // Verify error message is displayed
    expect(find.text('Failed to load movies'), findsOneWidget);

    // Verify that the loading indicator is gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Movie posters grid loads more movies when scrolled to the bottom', (WidgetTester tester) async {
    final posters1 = ['https://image.tmdb.org/t/p/w500/sample1.jpg'];
    final posters2 = ['https://image.tmdb.org/t/p/w500/sample2.jpg'];

    when(mockTMDbService.fetchMoviePosters(1)).thenAnswer((_) async => posters1);
    when(mockTMDbService.fetchMoviePosters(2)).thenAnswer((_) async => posters2);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => movieCubit,
          child: MovieListScreen(),
        ),
      ),
    );

    // Simulate initial fetch
    movieCubit.fetchMovies();
    await tester.pumpAndSettle();

    // Check initial posters
    expect(find.byType(CachedNetworkImage), findsNWidgets(1));

    // Scroll to the bottom to trigger loading more
    await tester.drag(find.byType(GridView), Offset(0, -500));
    await tester.pumpAndSettle();

    // Simulate fetching the next page of movies
    movieCubit.fetchMovies(loadMore: true);

    // Wait for the new data to be loaded
    await tester.pumpAndSettle();

    // Check that more posters have been added
    expect(find.byType(CachedNetworkImage), findsNWidgets(2)); // 1 + 1 more
  });
}