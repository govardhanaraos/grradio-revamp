// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackMetadataAdapter extends TypeAdapter<TrackMetadata> {
  @override
  final int typeId = 1;

  @override
  TrackMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackMetadata(
      filePath: fields[0] as String,
      title: fields[1] as String,
      album: fields[2] as String,
      artist: fields[3] as String,
      coverPath: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrackMetadata obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.album)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.coverPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
