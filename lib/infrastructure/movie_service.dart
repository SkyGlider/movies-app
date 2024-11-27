import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDbService {
  static const String _apiKey =
      '6489ad683fc50d1640cb90873c5343f9'; // Replace with your TMDb API Key
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Fetch list of popular movies
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