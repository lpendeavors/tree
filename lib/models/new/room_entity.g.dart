// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomEntity _$RoomEntityFromJson(Map<String, dynamic> json) {
  return RoomEntity(
    documentId: json['documentId'] as String,
    title: json['title'] as String,
    about: json['about'] as String,
    photo: json['photo'] as String,
    accessibility: json['accessibility'] as int,
    created: timestampFromJson(json['created'] as Timestamp),
  );
}

Map<String, dynamic> _$RoomEntityToJson(RoomEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'title': instance.title,
      'about': instance.about,
      'photo': instance.photo,
      'accessibility': instance.accessibility,
      'created': timestampToJson(instance.created),
    };
