import 'dart:convert';

import 'package:grradio/masstamilan/data/masstelugualbum.dart';
import 'package:grradio/masstamilan/data/masstelugualbumdetails.dart';
import 'package:http/http.dart' as http;

import '../../Env.dart';

class AlbumApi {
  final String baseUrl = Env.apiBaseUrl;

  // ── Route resolution ───────────────────────────────────────────────────────
  // [serviceRoute] — optional override from the remote download-screen config
  // (the "base_url" field in each album_entry, e.g. "masstelugu").
  // When provided it is used directly, bypassing the language→path switch.
  // When null the switch below runs as before.
  String _resolveRoute(String? language, {String? serviceRoute}) {
    if (serviceRoute != null && serviceRoute.isNotEmpty) return serviceRoute;
    switch (language?.toLowerCase()) {
      case 'telugu':
        return 'masstelugu';
      case 'hindi':
        return 'hindimp3bhai';
      case 'malayalam':
        return 'massmp3chetta';
      case 'tamil':
        return 'masstamilan';
      default:
        return 'masstelugu';
    }
  }

  Future<AlbumResponse> fetchAlbums({
    String? relativeUrl,
    String? language,
    String? serviceRoute, // optional override from MongoDB config
  }) async {
    final relPath = _resolveRoute(language, serviceRoute: serviceRoute);

    final uri = Uri.parse(
      (relativeUrl == null || relativeUrl == '')
          ? '$baseUrl/$relPath/albums'
          : '$baseUrl/$relPath/albums?relative_url=$relativeUrl',
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load albums');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    return AlbumResponse.fromJson(data);
  }

  Future<AlbumDetails> fetchAlbumDetails(
    String url,
    String? language, {
    String? serviceRoute, // optional override from MongoDB config
  }) async {
    final relPath = _resolveRoute(language, serviceRoute: serviceRoute);
    final encoded = Uri.encodeComponent(url);
    final res = await http.get(
      Uri.parse('$baseUrl/$relPath/albumdetails?url=$encoded'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load album details');
    }

    return AlbumDetails.fromJson(jsonDecode(res.body));
  }
}
