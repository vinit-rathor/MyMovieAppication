import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/movie_controller.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TmdbService service = TmdbService();
  final MovieController controller = Get.find<MovieController>();
  late Future<Movie> detailFuture;
  late Future<List<Map<String, dynamic>>> videosFuture;

  @override
  void initState() {
    super.initState();
    detailFuture = service.details(widget.movie);
    videosFuture = service.videos(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final backdrop = movie.backdropPath ?? movie.posterPath;
    final backdropUrl = backdrop == null
        ? null
        : '${ApiConfig.imageBaseUrl}${ApiConfig.backdropSize}$backdrop';
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: Get.back,
            ),
            actions: [
              Obx(() => IconButton(
                    onPressed: () => controller.toggleFavorite(movie),
                    icon: Icon(
                      controller.isFavorite(movie)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: controller.isFavorite(movie)
                          ? AppTheme.accent
                          : Colors.white,
                    ),
                    tooltip: 'Add to watchlist',
                  )),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdropUrl != null)
                    CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
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
                        colors: [Color(0x22000000), AppTheme.background],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: FutureBuilder<Movie>(
                future: detailFuture,
                builder: (context, snapshot) {
                  final detailed = snapshot.data ?? movie;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detailed.title,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05)),
                      if ((detailed.tagline ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(detailed.tagline!,
                            style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 14,
                        runSpacing: 10,
                        children: [
                          _meta(Icons.star_rounded,
                              detailed.rating.toStringAsFixed(1),
                              color: const Color(0xFFFFC857)),
                          _meta(Icons.calendar_month_rounded, detailed.year),
                          if (detailed.runtime != null &&
                              detailed.runtime! > 0)
                            _meta(Icons.schedule_rounded,
                                '${detailed.runtime} min'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openTrailer(),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Watch trailer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text('ABOUT THE MOVIE',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.6,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(
                        detailed.overview.isEmpty
                            ? 'No overview is available for this title yet.'
                            : detailed.overview,
                        style: const TextStyle(
                            fontSize: 15, height: 1.65, color: Colors.white70),
                      ),
                      const SizedBox(height: 25),
                      const Text('TRAILERS & CLIPS',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.6,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: videosFuture,
                        builder: (context, videoSnapshot) {
                          if (videoSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator(
                                color: AppTheme.accent);
                          }
                          final videos = videoSnapshot.data ?? [];
                          if (videos.isEmpty) {
                            return const Text(
                              'No YouTube trailer is listed for this movie.',
                              style: TextStyle(color: AppTheme.textMuted),
                            );
                          }
                          return Column(
                            children: videos.take(5).map((video) {
                              final key = (video['key'] ?? '').toString();
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 54,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.play_circle_fill,
                                      color: AppTheme.accent, size: 30),
                                ),
                                title: Text((video['name'] ?? 'Trailer').toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text((video['type'] ?? 'Video').toString(),
                                    style: const TextStyle(
                                        color: AppTheme.textMuted)),
                                trailing:
                                    const Icon(Icons.chevron_right_rounded),
                                onTap: () => _playVideo(key),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String value, {Color? color}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color ?? AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      );

  Future<void> _openTrailer() async {
    try {
      final videos = await videosFuture;
      if (videos.isEmpty) {
        Get.snackbar('Trailer unavailable',
            'TMDB does not list a YouTube trailer for this movie.');
        return;
      }
      final preferred = videos.firstWhere(
        (v) => (v['type'] ?? '').toString().toLowerCase() == 'trailer',
        orElse: () => videos.first,
      );
      _playVideo((preferred['key'] ?? '').toString());
    } catch (e) {
      Get.snackbar('Could not load trailer',
          e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _playVideo(String videoId) {
    if (videoId.isEmpty) {
      Get.snackbar('Video unavailable', 'This video has no YouTube ID.');
      return;
    }
    Get.to(() => TrailerPlayerScreen(
          title: widget.movie.title,
          videoId: videoId,
        ));
  }
}

class TrailerPlayerScreen extends StatefulWidget {
  final String title;
  final String videoId;
  const TrailerPlayerScreen(
      {super.key, required this.title, required this.videoId});

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late final YoutubePlayerController playerController;

  @override
  void initState() {
    super.initState();
    playerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, maxLines: 1)),
      body: Center(
        child: YoutubePlayer(
          controller: playerController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.accent,
        ),
      ),
    );
  }
}
