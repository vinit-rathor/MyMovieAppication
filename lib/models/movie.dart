class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double rating;
  final List<int> genreIds;
  final String? tagline;
  final int? runtime;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate = '',
    this.rating = 0,
    this.genreIds = const [],
    this.tagline,
    this.runtime,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        id: json['id'] is int ? json['id'] as int : 0,
        title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),
        overview: (json['overview'] ?? '').toString(),
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        releaseDate: (json['release_date'] ?? '').toString(),
        rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
        genreIds: (json['genre_ids'] as List<dynamic>? ?? [])
            .whereType<num>()
            .map((e) => e.toInt())
            .toList(),
        tagline: json['tagline'] as String?,
        runtime: (json['runtime'] as num?)?.toInt(),
      );

  Movie copyWith({
    String? tagline,
    int? runtime,
  }) =>
      Movie(
        id: id,
        title: title,
        overview: overview,
        posterPath: posterPath,
        backdropPath: backdropPath,
        releaseDate: releaseDate,
        rating: rating,
        genreIds: genreIds,
        tagline: tagline ?? this.tagline,
        runtime: runtime ?? this.runtime,
      );

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '—';
}
