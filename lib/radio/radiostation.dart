import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

part 'radiostation.g.dart';

@HiveType(typeId: 0)
class RadioStation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? logoUrl;

  @HiveField(3)
  final String? streamUrl;

  @HiveField(4)
  final String? language;

  @HiveField(5)
  final String? genre;

  @HiveField(6)
  final String? state;

  @HiveField(7)
  final String? page;

  const RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.language,
    this.genre,
    this.state,
    this.page,
  });

  /// Picks a non-empty logo URL from common API field names so Hive cache + UI show art.
  static String? _parseLogoUrl(Map<String, dynamic> map) {
    String? asTrimmedString(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    for (final key in const [
      'logoUrl',
      'logo',
      'image',
      'imageUrl',
      'artwork',
      'art',
      'coverUrl',
      'cover_url',
      'thumbnail',
      'photo',
      'icon',
    ]) {
      final u = asTrimmedString(map[key]);
      if (u != null) return u;
    }
    return null;
  }

  /// Parses the stations API JSON object, e.g.:
  /// ```json
  /// {
  ///   "id": "0010",
  ///   "name": "Akashvani Almora",
  ///   "logoUrl": "https://...",
  ///   "streamUrl": "https://...",
  ///   "Language": "Garhwali, Hindi",
  ///   "genre": "UTTARAKHAND",
  ///   "page": "channel-akashvani-almora-..."
  /// }
  /// ```
  /// `genre` holds the region/state label; `genre` and `state` on the model both use that value.
  factory RadioStation.fromMap(Map<String, dynamic> map) {
    final rawId = map['id']?.toString().trim();
    final idString = (rawId != null && rawId.isNotEmpty)
        ? rawId
        : (map['_id']?.toString() ?? '');

    final languageFromMap =
        map['Language'] as String? ?? map['language'] as String?;

    final region = map['genre'] as String?;
    final pageFromMap = map['page'] as String?;

    return RadioStation(
      id: idString,
      name: map['name']?.toString().trim() ?? '',
      streamUrl: map['streamUrl']?.toString().trim() ?? '',
      logoUrl: _parseLogoUrl(map),
      language: languageFromMap,
      genre: region,
      state: region,
      page: pageFromMap,
    );
  }

  MediaItem toMediaItem() => MediaItem(
    id: id,
    title: name,
    artist: state ?? 'Radio Station', // Use state as the artist/subtitle
    artUri: logoUrl != null
        ? Uri.parse(logoUrl!)
        : Uri.parse("asset:///assets/images/default_radio_icon.png"),
    extras: <String, dynamic>{
      'streamUrl': streamUrl,
      'language': language,
      'genre': genre,
      'state': state,
      'page': page,
    },
  );

  RadioStation copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? language,
    String? genre,
    String? state,
    String? page,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      language: language ?? this.language,
      genre: genre ?? this.genre,
      state: state ?? this.state,
      page: page ?? this.page,
    );
  }
}
