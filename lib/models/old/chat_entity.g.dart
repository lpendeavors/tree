// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatEntity _$ChatEntityFromJson(Map<String, dynamic> json) {
  return ChatEntity(
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    churchName: json['churchName'] as String,
    fullName: json['fullName'] as String,
    isChurch: json['isChurch'] as bool,
    documentId: json['documentId'] as String,
    image: json['image'] as String,
    ownerId: json['ownerId'] as String,
    byAdmin: json['byAdmin'] as bool,
    message: json['message'] as String,
    parties: (json['parties'] as List)?.map((e) => e as String)?.toList(),
    chatId: json['chatId'] as String,
    isRoom: json['isRoom'] as bool,
    readBy: (json['readBy'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ChatEntityToJson(ChatEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'byAdmin': instance.byAdmin,
      'chatId': instance.chatId,
      'churchName': instance.churchName,
      'fullName': instance.fullName,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isRoom': instance.isRoom,
      'message': instance.message,
      'ownerId': instance.ownerId,
      'parties': instance.parties,
      'readBy': instance.readBy,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
