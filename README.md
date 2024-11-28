# Movie Posters

A movie posters app

## Getting Started

This project is a infinite-scrolling movie poster app with data source from TMDB, The Movie Database (https://www.themoviedb.org/) built with flutter cubit and equatable states.

Compilation instructions:
1. Clone the repository
2. Ensure latest version of flutter (>3.24.5) is installed
3. Ensure AVD with (ideally, >Android 15) is installed
4. Run "flutter pub get"
5. Add your API Key from TMDB in movie_repository.dart (this should've been an .env file)
6. Compile and run

## Architecture: Domain Driven Design

Infrastructure level: 
1. infrastructure/movie_repository.dart - repository that handles all api calls to external services

Application level:
1. cubits/movie_cubit.dart - handles the emitting and switching of states
2. cubits/movie_state.dart - contains all possible states of the app

Presentation level: 
1. main.dart - app view components

## Testing Instructions

Unit testing and widget testing are available in the /test folder. 
1. First run "dart run build_runner build" to generate the mocks (@GenerateMocks)
2. Run unit tests in cubit_test.dart
3. Run widget tests in widget-test.dart
