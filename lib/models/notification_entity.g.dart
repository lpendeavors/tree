// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) {
  return NotificationEntity(
    visibility: json['visibility'] as int,
    databaseName: json['databaseName'] as String,
    timeUpdated: json['timeUpdated'] as int,
    documentId: json['documentId'] as String,
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    tokenID: json['tokenID'] as String,
    fullName: json['fullName'] as String,
    image: json['image'] as String,
    docId: json['docId'] as String,
    time: json['time'] as int,
    readBy: (json['readBy'] as List)?.map((e) => e as String)?.toList(),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    message: json['message'] as String,
    postId: json['postId'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    notificationType: json['notificationType'] as int,
    ownerId: json['ownerId'] as String,
    status: json['status'] as int,
  );
}

Map<String, dynamic> _$NotificationEntityToJson(NotificationEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'body': instance.body,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'fullName': instance.fullName,
      'image': instance.image,
      'message': instance.message,
      'notificationType': instance.notificationType,
      'ownerId': instance.ownerId,
      'postId': instance.postId,
      'readBy': instance.readBy,
      'status': instance.status,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'title': instance.title,
      'tokenID': instance.tokenID,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
