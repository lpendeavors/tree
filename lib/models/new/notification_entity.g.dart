// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) {
  return NotificationEntity(
    documentId: json['documentId'] as String,
    body: json['body'] as String,
    global: json['global'] as bool,
    readBy: (json['readBy'] as List)?.map((e) => e as String)?.toList(),
    title: json['title'] as String,
    tokenID: json['tokenID'] as String,
    type: json['type'] as int,
    sender: json['sender'] as String,
    image: json['image'] as String,
    date: timestampFromJson(json['date'] as Timestamp),
  );
}

Map<String, dynamic> _$NotificationEntityToJson(NotificationEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'body': instance.body,
      'global': instance.global,
      'readBy': instance.readBy,
      'title': instance.title,
      'tokenID': instance.tokenID,
      'type': instance.type,
      'sender': instance.sender,
      'image': instance.image,
      'date': timestampToJson(instance.date),
    };
