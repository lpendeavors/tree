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
    groupName: json['groupName'] as String,
    isChurch: json['isChurch'] as bool,
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
    groupDescription: json['groupDescription'] as String,
    isConversation: json['isConversation'] as bool,
    isGroupPrivate: json['isGroupPrivate'] as bool,
    canPostOnWall: json['canPostOnWall'] as bool,
  );
}

Map<String, dynamic> _$GroupEntityToJson(GroupEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'byAdmin': instance.byAdmin,
      'groupName': instance.groupName,
      'groupId': instance.groupId,
      'groupImage': instance.groupImage,
      'groupMembers': instance.groupMembers?.map((e) => e?.toJson())?.toList(),
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isConversation': instance.isConversation,
      'isGroup': instance.isGroup,
      'isGroupPrivate': instance.isGroupPrivate,
      'isRoom': instance.isRoom,
      'ownerId': instance.ownerId,
      'uid': instance.uid,
      'groupDescription': instance.groupDescription,
      'canPostOnWall': instance.canPostOnWall,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
