class Track {
  final int position;
  final String name;
  final String singers;
  final String duration;
  final String? download128;
  final String? download320;

  Track({
    required this.position,
    required this.name,
    required this.singers,
    required this.duration,
    this.download128,
    this.download320,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    position: json['position'],
    name: json['name'],
    singers: json['singers'],
    duration: json['duration'],
    download128: json['download_128'],
    download320: json['download_320'],
  );
}

class AlbumDetails {
  final String albumName;
  final String albumArt;
  final String? starring;
  final String? music;
  final String? director;
  final String? lyricists;
  final String? year;
  final String? language;
  final List<Track> tracks;

  AlbumDetails({
    required this.albumName,
    required this.albumArt,
    this.starring,
    this.music,
    this.director,
    this.lyricists,
    this.year,
    this.language,
    required this.tracks,
  });

  factory AlbumDetails.fromJson(Map<String, dynamic> json) => AlbumDetails(
    albumName: json['album_name'],
    albumArt: json['album_art'],
    starring: json['starring'],
    music: json['music'],
    director: json['director'],
    lyricists: json['lyricists'],
    year: json['year'],
    language: json['language'],
    tracks: (json['tracks'] as List).map((e) => Track.fromJson(e)).toList(),
  );
}
