import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieRepository {
  static const String _apiKey =
      'YOUR_TMDD_API_KEY'; // TMDB API Key
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // GET Request
  Future<List<String>> fetchMoviePosters(int page) async {
    final url =
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      return results.map((movie) {
        return 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';
      }).toList();
    } else {
      throw Exception('Failed to get posters');
    }
  }
}
