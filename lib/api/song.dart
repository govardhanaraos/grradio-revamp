class Song {
  final String title;
  final String url;

  Song({required this.title, required this.url});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: (json['song_name'] ?? json['title'] ?? '') as String,
      url: (json['blomp_url'] ?? json['url'] ?? '') as String,
    );
  }
}
