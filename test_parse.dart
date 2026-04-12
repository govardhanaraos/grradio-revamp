import 'dart:convert';

void main() {
  const response = '''[{"song_name":"Kala Chashma","album_name":"Baar Baar Dekho (2016)","blomp_url":"https://api.blomp.com/download?path=2479_06_-_Kala_Chashma_128kbps.mp3&hash=5a815b808c91a5a6b2bb756ca2b55789&temp_token=generated"},{"song_name":"Tera Hone Laga Hoon","album_name":"Ajab Prem Ki Ghazab Kahani (2009)","blomp_url":"https://api.blomp.com/download?path=6673_04_-_Tera_Hone_Laga_Hoon_128kbps.mp3&hash=d67735bd1ca665da6f2e28c9e03ba7ab&temp_token=generated"}]''';

  try {
    final decoded = json.decode(response);
    
    List<dynamic> songsList = [];
    if (decoded is List) {
      songsList = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['songs'] != null) {
      songsList = decoded['songs'] as List;
    }
    
    print("songsList: \$songsList");
    
    final songs = songsList.map((songJson) {
       print("songJson: \$songJson");
       return Song.fromJson(songJson as Map<String, dynamic>);
    }).toList();
    print("Parsed \${songs.length} songs");
  } catch (e) {
    print("Error: \$e");
  }
}

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
