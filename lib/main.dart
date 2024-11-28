import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies/cubits/movie_cubit.dart';
import 'package:movies/infrastructure/movie_repository.dart';


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
        create: (_) => MovieCubit(MovieRepository()),
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

    context.read<MovieCubit>().fetchMovies();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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
            if (state is MovieInitial || (state is MovieLoading && state.posters.isEmpty)) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return const Card(
                    elevation: 8.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              );
            } else if (state is MovieError) {
              return Center(child: Text(state.errorMessage));
            } else if (state is MovieLoaded) {
              return GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: state.posters.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.posters.length) {
                    return state is MovieLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  final posterUrl = state.posters[index];
                  return Card(
                    elevation: 8.0,
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
