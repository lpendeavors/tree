// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventData _$EventDataFromJson(Map<String, dynamic> json) {
  return EventData(
    assetType: json['assetType'] as int,
    type: json['type'] as int,
    docId: json['docId'] as String,
    imageUrl: json['imageUrl'] as String,
    imagePath: json['imagePath'] as String,
    assetFile: json['assetFile'] as String,
  );
}

Map<String, dynamic> _$EventDataToJson(EventData instance) => <String, dynamic>{
      'assetFile': instance.assetFile,
      'assetType': instance.assetType,
      'docId': instance.docId,
      'imagePath': instance.imagePath,
      'imageUrl': instance.imageUrl,
      'type': instance.type,
    };
