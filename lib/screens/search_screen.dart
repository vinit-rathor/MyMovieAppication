import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/movie_controller.dart';
import '../core/app_theme.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MovieController controller = Get.find<MovieController>();
  final TextEditingController textController = TextEditingController();
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover movies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: TextField(
              controller: textController,
              autofocus: true,
              onChanged: (value) {
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 450),
                    () => controller.search(value));
              },
              decoration: InputDecoration(
                hintText: 'Search a title, actor, or story...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    textController.clear();
                    controller.search('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent));
              }
              if (controller.searchError.value.isNotEmpty) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(controller.searchError.value,
                      textAlign: TextAlign.center),
                ));
              }
              if (textController.text.trim().isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie_filter_outlined,
                          size: 58, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text('Find your next favourite',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 15)),
                    ],
                  ),
                );
              }
              if (controller.searchResults.isEmpty) {
                return const Center(
                    child: Text('No movies found',
                        style: TextStyle(color: AppTheme.textMuted)));
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .48,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.searchResults.length,
                itemBuilder: (_, index) {
                  final movie = controller.searchResults[index];
                  return MovieCard(
                    movie: movie,
                    compact: true,
                    onTap: () =>
                        Get.to(() => MovieDetailScreen(movie: movie)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
