import 'package:get/get.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieController extends GetxController {
  final TmdbService service = TmdbService();

  final trendingMovies = <Movie>[].obs;
  final popularMovies = <Movie>[].obs;
  final topRatedMovies = <Movie>[].obs;
  final upcomingMovies = <Movie>[].obs;
  final searchResults = <Movie>[].obs;
  final favorites = <int>{}.obs;
  final isLoading = false.obs;
  final isSearching = false.obs;
  final error = ''.obs;
  final searchError = ''.obs;
  final selectedGenre = 'All'.obs;

  final genres = const <String, int>{
    'All': 0,
    'Action': 28,
    'Comedy': 35,
    'Drama': 18,
    'Horror': 27,
    'Sci-Fi': 878,
    'Romance': 10749,
    'Animation': 16,
  };

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        service.trending(),
        service.popular(),
        service.topRated(),
        service.upcoming(),
      ]);
      trendingMovies.assignAll(results[0]);
      popularMovies.assignAll(results[1]);
      topRatedMovies.assignAll(results[2]);
      upcomingMovies.assignAll(results[3]);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      searchError.value = '';
      return;
    }
    isSearching.value = true;
    searchError.value = '';
    try {
      searchResults.assignAll(await service.search(query.trim()));
    } catch (e) {
      searchError.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSearching.value = false;
    }
  }

  List<Movie> byGenre(List<Movie> movies) {
    final id = genres[selectedGenre.value] ?? 0;
    if (id == 0) return movies;
    return movies.where((m) => m.genreIds.contains(id)).toList();
  }

  bool isFavorite(Movie movie) => favorites.contains(movie.id);

  void toggleFavorite(Movie movie) {
    if (favorites.contains(movie.id)) {
      favorites.remove(movie.id);
    } else {
      favorites.add(movie.id);
    }
    favorites.refresh();
  }
}
