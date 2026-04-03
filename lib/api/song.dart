class Song {
  final String title;
  final String url;

  Song({required this.title, required this.url});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}
