import 'package:hive/hive.dart';

part 'track_metadata.g.dart';

@HiveType(typeId: 1)
class TrackMetadata {
  @HiveField(0)
  String filePath;

  @HiveField(1)
  String title;

  @HiveField(2)
  String album;

  @HiveField(3)
  String artist;

  @HiveField(4)
  String coverPath;

  TrackMetadata({
    required this.filePath,
    required this.title,
    required this.album,
    required this.artist,
    required this.coverPath,
  });
}
