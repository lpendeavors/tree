import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'event_data.g.dart';

@immutable
@JsonSerializable()
class EventData extends Equatable {
  final String assetFile;
  final int assetType;
  final String docId;
  final String imagePath;
  final String imageUrl;
  final int type;

  const EventData({
    this.assetType,
    this.type,
    this.docId,
    this.imageUrl,
    this.imagePath,
    this.assetFile,
  });

  factory EventData.fromJson(Map<String, dynamic> json) => _$EventDataFromJson(json);
  Map<String, dynamic> toJson() => _$EventDataToJson(this);

  @override
  List get props {
    return [
      assetFile,
      assetType,
      docId,
      imagePath,
      imageUrl,
    ];
  }

  @override
  bool get stringify => true;
}