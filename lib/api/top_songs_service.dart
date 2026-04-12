import 'dart:convert';

import 'package:grradio/Env.dart';
import 'package:grradio/api/song.dart';
import 'package:http/http.dart' as http;

class TopSongsService {
  Future<List<Song>> fetchTopSongs(String languageCode) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/v1/ai/top-songs?language=$languageCode');

    try {
      final response = await _getWithRetry(uri);
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        
        List<dynamic> songsList = [];
        if (decoded is List) {
          songsList = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['songs'] != null) {
          songsList = decoded['songs'] as List;
        }
        
        final songs = songsList
            .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
            .toList();
        return songs;
      } else {
        print(
          'API returned status ${response.statusCode}. Falling back to mock data.',
        );
        return _getMockSongs();
      }
    } catch (e) {
      print('Failed to fetch top songs: $e. Falling back to mock data.');
      return _getMockSongs();
    }
  }

  /// Retries transient TLS/HTTP failures.
  Future<http.Response> _getWithRetry(Uri uri) async {
    const maxAttempts = 3;
    Object? lastErr;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await http.get(uri).timeout(Duration(seconds: 10 + attempt * 5));
      } catch (e) {
        lastErr = e;
        print("Attempt ${attempt + 1} to fetch from $uri failed: $e");
        if (attempt < maxAttempts - 1) {
          final delay = Duration(milliseconds: 500 * (1 << attempt));
          print("Waiting ${delay.inMilliseconds}ms before retrying...");
          await Future<void>.delayed(delay);
        }
      }
    }
    throw lastErr ?? Exception('GET failed after $maxAttempts attempts');
  }

  List<Song> _getMockSongs() {
    const jsonResponse = '''
    {
      "songs": [
        {"title": "Trending Hit - Vocals", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"},
        {"title": "Classic Acoustic Mix", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"},
        {"title": "Lo-Fi Deep Focus", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"},
        {"title": "Electronic Dance Beat", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"},
        {"title": "Ambient Chillwave", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3"},
        {"title": "Jazz Lounge Session", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3"},
        {"title": "Upbeat Pop Anthem", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3"},
        {"title": "Cinematic Soundtrack", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3"},
        {"title": "Midnight Blues", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3"},
        {"title": "Indie Rock Groove", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3"}
      ]
    }
    ''';
    final decoded = json.decode(jsonResponse) as Map<String, dynamic>;
    final songs = (decoded['songs'] as List)
        .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
        .toList();
    return songs;
  }
}
