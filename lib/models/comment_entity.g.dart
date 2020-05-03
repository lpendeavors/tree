// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentEntity _$CommentEntityFromJson(Map<String, dynamic> json) {
  return CommentEntity(
    documentId: json['documentId'] as String,
    body: json['body'] as String,
    likes: (json['likes'] as List)?.map((e) => e as String)?.toList(),
    owner: json['owner'] == null
        ? null
        : OwnerData.fromJson(json['owner'] as Map<String, dynamic>),
    parent: json['parent'] as String,
    date: timestampFromJson(json['date'] as Timestamp),
  );
}

Map<String, dynamic> _$CommentEntityToJson(CommentEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'body': instance.body,
      'likes': instance.likes,
      'owner': instance.owner?.toJson(),
      'parent': instance.parent,
      'date': timestampToJson(instance.date),
    };
