// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) {
  return GroupMember(
    groupId: json['groupId'] as String,
    uid: json['uid'] as String,
    image: json['image'] as String,
    tokenID: json['tokenID'] as String,
    fullName: json['fullName'] as String,
    groupAdmin: json['groupAdmin'] as bool,
  );
}

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'fullName': instance.fullName,
      'groupAdmin': instance.groupAdmin,
      'image': instance.image,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
    };
