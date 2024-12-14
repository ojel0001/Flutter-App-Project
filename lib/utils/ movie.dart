class Movie {
  final String title;
  final String releaseDate;
  final String posterPath;

  Movie({
    required this.title,
    required this.releaseDate,
    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] as String,
      releaseDate: json['release_date'] as String,
      posterPath: json['poster_path'] as String,
    );
  }
}
