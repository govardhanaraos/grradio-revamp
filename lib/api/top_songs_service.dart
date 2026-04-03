import 'dart:convert';

import 'package:grradio/Env.dart';
import 'package:grradio/api/song.dart';
import 'package:http/http.dart' as http;

class TopSongsService {
  Future<List<Song>> fetchTopSongs(String languageCode) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/top-songs?lang=$languageCode');

    try {
      final response = await _getWithRetry(uri);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final songs = (decoded['songs'] as List)
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
        {"title": "Song 1", "url": "http://example.com/song1.mp3"},
        {"title": "Song 2", "url": "http://example.com/song2.mp3"},
        {"title": "Song 3", "url": "http://example.com/song3.mp3"},
        {"title": "Song 4", "url": "http://example.com/song4.mp3"},
        {"title": "Song 5", "url": "http://example.com/song5.mp3"},
        {"title": "Song 6", "url": "http://example.com/song6.mp3"},
        {"title": "Song 7", "url": "http://example.com/song7.mp3"},
        {"title": "Song 8", "url": "http://example.com/song8.mp3"},
        {"title": "Song 9", "url": "http://example.com/song9.mp3"},
        {"title": "Song 10", "url": "http://example.com/song10.mp3"}
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
