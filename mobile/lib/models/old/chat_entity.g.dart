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
    documentId: json['documentId'] as String,
    time: json['time'] as int,
    image: json['image'] as String,
    ownerId: json['ownerId'] as String,
    byAdmin: json['byAdmin'] as bool,
    message: json['message'] as String,
    type: json['type'] as int,
    parties: (json['parties'] as List)?.map((e) => e as String)?.toList(),
    chatId: json['chatId'] as String,
    isRoom: json['isRoom'] as bool,
    readBy: (json['readBy'] as List)?.map((e) => e as String)?.toList(),
    showDate: json['showDate'] as bool,
    imagePath: json['imagePath'] as String,
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
      'isRoom': instance.isRoom,
      'message': instance.message,
      'ownerId': instance.ownerId,
      'parties': instance.parties,
      'readBy': instance.readBy,
      'showDate': instance.showDate,
      'time': instance.time,
      'type': instance.type,
      'imagePath': instance.imagePath,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
