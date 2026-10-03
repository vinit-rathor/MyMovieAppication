import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final bool compact;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final poster = movie.posterPath == null
        ? null
        : '${ApiConfig.imageBaseUrl}${ApiConfig.posterSize}${movie.posterPath}';
    return SizedBox(
      width: compact ? 128 : 145,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: poster == null
                    ? _placeholder()
                    : CachedNetworkImage(
                        imageUrl: poster,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFC857)),
                const SizedBox(width: 3),
                Text(movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(width: 8),
                Text(movie.year,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.surfaceLight,
        child: const Center(
          child: Icon(Icons.movie_creation_outlined,
              color: AppTheme.textMuted, size: 36),
        ),
      );
}
