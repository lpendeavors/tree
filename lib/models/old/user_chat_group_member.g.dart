// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_chat_group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChatGroupMember _$UserChatGroupMemberFromJson(Map<String, dynamic> json) {
  return UserChatGroupMember(
    uid: json['uid'] as String,
    image: json['image'] as String,
    fullName: json['fullName'] as String,
    docId: json['docId'] as String,
    groupAdmin: json['groupAdmin'] as bool,
    tokenID: json['tokenID'] as String,
  );
}

Map<String, dynamic> _$UserChatGroupMemberToJson(
        UserChatGroupMember instance) =>
    <String, dynamic>{
      'docId': instance.docId,
      'fullName': instance.fullName,
      'groupAdmin': instance.groupAdmin,
      'image': instance.image,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
    };
