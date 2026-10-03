import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../models/movie.dart';

class TmdbService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    queryParameters: {'api_key': ApiConfig.apiKey, 'language': 'en-US'},
  ));

  bool get hasApiKey =>
      ApiConfig.apiKey.trim().isNotEmpty &&
      ApiConfig.apiKey != 'YOUR_TMDB_API_KEY';

  Future<List<Movie>> _movieList(String path,
      {Map<String, dynamic>? params}) async {
    if (!hasApiKey) {
      throw Exception('Add your TMDB API key in lib/core/api_config.dart');
    }
    final response = await _dio.get(path, queryParameters: params);
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }

  Future<List<Movie>> trending() => _movieList('/trending/movie/week');
  Future<List<Movie>> popular() => _movieList('/movie/popular');
  Future<List<Movie>> topRated() => _movieList('/movie/top_rated');
  Future<List<Movie>> upcoming() => _movieList('/movie/upcoming');

  Future<List<Movie>> search(String query) =>
      _movieList('/search/movie', params: {'query': query});

  Future<Movie> details(Movie movie) async {
    if (!hasApiKey) {
      throw Exception('Add your TMDB API key in lib/core/api_config.dart');
    }
    final response = await _dio.get('/movie/${movie.id}');
    return Movie.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> videos(int movieId) async {
    if (!hasApiKey) {
      throw Exception('Add your TMDB API key in lib/core/api_config.dart');
    }
    final response = await _dio.get('/movie/$movieId/videos');
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results.whereType<Map<String, dynamic>>().where((video) {
      final site = (video['site'] ?? '').toString().toLowerCase();
      final type = (video['type'] ?? '').toString().toLowerCase();
      return site == 'youtube' &&
          (type == 'trailer' || type == 'teaser' || type == 'clip');
    }).toList();
  }
}
