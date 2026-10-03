import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/movie_controller.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final MovieController controller = Get.find<MovieController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.trendingMovies.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (controller.error.value.isNotEmpty &&
              controller.trendingMovies.isEmpty) {
            return _errorState();
          }
          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: controller.loadHome,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(context)),
                if (controller.trendingMovies.isNotEmpty)
                  SliverToBoxAdapter(
                      child: _hero(controller.trendingMovies.first, context)),
                SliverToBoxAdapter(
                    child: _genreStrip()),
                _movieSection('Trending This Week',
                    controller.byGenre(controller.trendingMovies), context),
                _movieSection('Popular Movies',
                    controller.byGenre(controller.popularMovies), context),
                _movieSection('Top Rated',
                    controller.byGenre(controller.topRatedMovies), context),
                _movieSection('Coming Soon',
                    controller.byGenre(controller.upcomingMovies), context),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CINEWAVE',
                    style: TextStyle(
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w900,
                        fontSize: 17)),
                Text('Your cinema, everywhere',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Get.to(() => SearchScreen()),
              icon: const Icon(Icons.search_rounded, size: 27),
              tooltip: 'Search movies',
            ),
          ],
        ),
      );

  Widget _hero(Movie movie, BuildContext context) {
    final image = movie.backdropPath ?? movie.posterPath;
    final url = image == null
        ? null
        : '${ApiConfig.imageBaseUrl}${ApiConfig.backdropSize}$image';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 390,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null)
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.surface),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppTheme.surface),
                )
              else
                Container(color: AppTheme.surface),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0x44000000),
                      Color(0xF0090B10),
                    ],
                    stops: [0, .35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text('WEEKLY SPOTLIGHT',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 12),
                    Text(movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 30,
                            height: 1.05,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC857), size: 18),
                        const SizedBox(width: 4),
                        Text(movie.rating.toStringAsFixed(1)),
                        const SizedBox(width: 12),
                        Text(movie.year,
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(width: 12),
                        const Text('TRENDING',
                            style: TextStyle(
                                color: Colors.white70,
                                letterSpacing: 1,
                                fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(
                            () => MovieDetailScreen(movie: movie)),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Explore movie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genreStrip() => SizedBox(
        height: 56,
        child: Obx(() => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: controller.genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final genre = controller.genres.keys.elementAt(index);
                final active = controller.selectedGenre.value == genre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: active,
                  onSelected: (_) => controller.selectedGenre.value = genre,
                  selectedColor: AppTheme.accent,
                  backgroundColor: AppTheme.surface,
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            )),
      );

  Widget _movieSection(
      String title, List<Movie> movies, BuildContext context) {
    if (movies.isEmpty) {
      return SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ));
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800)),
                  ),
                  const Text('VIEW ALL',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 13),
            SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 13),
                itemBuilder: (_, i) => MovieCard(
                  movie: movies[i],
                  onTap: () => Get.to(
                      () => MovieDetailScreen(movie: movies[i])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 54, color: AppTheme.textMuted),
              const SizedBox(height: 18),
              const Text('Could not load movies',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(controller.error.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 18),
              ElevatedButton(
                  onPressed: controller.loadHome,
                  child: const Text('Try again')),
            ],
          ),
        ),
      );
}
