// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyEntity _$ReplyEntityFromJson(Map<String, dynamic> json) {
  return ReplyEntity(
    databaseName: json['databaseName'] as String,
    visibility: json['visibility'] as int,
    timeUpdated: json['timeUpdated'] as int,
    documentId: json['documentId'] as String,
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    time: json['time'] as int,
    postId: json['postId'] as String,
    postMessage: json['postMessage'] as String,
  );
}

Map<String, dynamic> _$ReplyEntityToJson(ReplyEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'databaseName': instance.databaseName,
      'postId': instance.postId,
      'postMessage': instance.postMessage,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
