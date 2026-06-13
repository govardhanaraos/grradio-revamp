class Song {
  final String title;
  final String url;
  final String? authToken; // Add this field
  final String? albumName;

  Song({
    required this.title,
    required this.url,
    this.authToken,
    this.albumName,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['song_name'] ?? 'Unknown Title',
      albumName: json['album_name'] ?? '',
      url: json['blomp_url'] ?? '',
      authToken: json['auth_token'], // Parse the token from Python
    );
  }
}
