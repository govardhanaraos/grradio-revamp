import 'package:grradio/data/track_metadata.dart';
import 'package:hive/hive.dart';

class TrackMetadataService {
  static const String boxName = 'tracks';

  /// Save metadata
  static Future<void> saveTrackMetadata(TrackMetadata metadata) async {
    final box = await Hive.openBox<TrackMetadata>(boxName);
    await box.put(metadata.filePath, metadata);
  }

  /// Retrieve metadata by file path
  static Future<TrackMetadata?> getTrackMetadata(String filePath) async {
    final box = await Hive.openBox<TrackMetadata>(boxName);
    return box.get(filePath);
  }

  /// Get all tracks
  static Future<List<TrackMetadata>> getAllTracks() async {
    final box = await Hive.openBox<TrackMetadata>(boxName);
    return box.values.toList();
  }
}
