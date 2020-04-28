// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageEntity _$MessageEntityFromJson(Map<String, dynamic> json) {
  return MessageEntity(
    documentId: json['documentId'] as String,
    body: json['body'] as String,
    sender: json['sender'] == null
        ? null
        : OwnerData.fromJson(json['sender'] as Map<String, dynamic>),
    asset: json['asset'] == null
        ? null
        : AssetData.fromJson(json['asset'] as Map<String, dynamic>),
    date: timestampFromJson(json['date'] as Timestamp),
  );
}

Map<String, dynamic> _$MessageEntityToJson(MessageEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'body': instance.body,
      'sender': instance.sender?.toJson(),
      'asset': instance.asset?.toJson(),
      'date': timestampToJson(instance.date),
    };
