import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'cubits/movie_cubit.dart';
import 'infrastructure/movie_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Posters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => MovieCubit(TMDbService()),
        child: MovieListScreen(),
      ),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Fetch the initial list of movies
    context.read<MovieCubit>().fetchMovies();

    // Listen for the scroll position to load more data
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Fetch more movies when scrolled to the bottom
        context.read<MovieCubit>().fetchMovies(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Popular Movies',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ))),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<MovieCubit, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading && state.props.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MovieError) {
              return Center(child: Text(state.message));
            } else if (state is MovieLoaded) {
              return GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: 8.0, // Horizontal spacing between columns
                  mainAxisSpacing: 8.0, // Vertical spacing between rows
                  childAspectRatio:
                      0.7, // Adjust aspect ratio to make the images look good
                ),
                itemCount:
                    state.posters.length + 1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index == state.posters.length) {
                    // Display loading indicator at the bottom
                    return state is MovieLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }

                  final posterUrl = state.posters[index];
                  return Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(4.0), // Rounded corners
                    ),
                    child: CachedNetworkImage(
                      imageUrl: posterUrl,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  );
                },
              );
            } else {
              return Center(
                  child: ElevatedButton(
                onPressed: () => context.read<MovieCubit>().fetchMovies(),
                child: const Text('Fetch Movies'),
              ));
            }
          },
        ),
      ),
    );
  }
}
