// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupEntity _$GroupEntityFromJson(Map<String, dynamic> json) {
  return GroupEntity(
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    ownerId: json['ownerId'] as String,
    byAdmin: json['byAdmin'] as bool,
    documentId: json['documentId'] as String,
    fullName: json['fullName'] as String,
    image: json['image'] as String,
    uid: json['uid'] as String,
    isRoom: json['isRoom'] as bool,
    isGroup: json['isGroup'] as bool,
    groupId: json['groupId'] as String,
    groupImage: json['groupImage'] as String,
    groupMembers: (json['groupMembers'] as List)
        ?.map((e) =>
            e == null ? null : GroupMember.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    isConversation: json['isConversation'] as bool,
    isGroupPrivate: json['isGroupPrivate'] as bool,
  );
}

Map<String, dynamic> _$GroupEntityToJson(GroupEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'byAdmin': instance.byAdmin,
      'fullName': instance.fullName,
      'groupId': instance.groupId,
      'groupImage': instance.groupImage,
      'groupMembers': instance.groupMembers?.map((e) => e?.toJson())?.toList(),
      'image': instance.image,
      'isConversation': instance.isConversation,
      'isGroup': instance.isGroup,
      'isGroupPrivate': instance.isGroupPrivate,
      'isRoom': instance.isRoom,
      'ownerId': instance.ownerId,
      'uid': instance.uid,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
