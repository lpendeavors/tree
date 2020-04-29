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
    isAdmin: json['isAdmin'] as bool,
    documentId: json['documentId'] as String,
    timeUpdated: json['timeUpdated'] as int,
    churchName: json['churchName'] as String,
    databaseName: json['databaseName'] as String,
    fullName: json['fullName'] as String,
    isChurch: json['isChurch'] as bool,
    isVerified: json['isVerified'] as bool,
    phoneNo: json['phoneNo'] as String,
    pushNotificationToken: json['pushNotificationToken'] as String,
    userImage: json['userImage'] as String,
    visibility: json['visibility'] as int,
    tokenID: json['tokenID'] as String,
    searchData: (json['searchData'] as List)?.map((e) => e as String)?.toList(),
    time: json['time'] as int,
    email: json['email'] as String,
    image: json['image'] as String,
    username: json['username'] as String,
    uid: json['uid'] as String,
    gender: json['gender'] as int,
    docId: json['docId'] as String,
    isRoom: json['isRoom'] as bool,
    country: json['country'] as String,
    isGroup: json['isGroup'] as bool,
    creatorsMessage: json['creatorsMessage'] as String,
    groupId: json['groupId'] as String,
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
      'isAdmin': instance.isAdmin,
      'churchName': instance.churchName,
      'country': instance.country,
      'creatorsMessage': instance.creatorsMessage,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'email': instance.email,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'groupId': instance.groupId,
      'groupMembers': instance.groupMembers?.map((e) => e?.toJson())?.toList(),
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isConversation': instance.isConversation,
      'isGroup': instance.isGroup,
      'isGroupPrivate': instance.isGroupPrivate,
      'isRoom': instance.isRoom,
      'isVerified': instance.isVerified,
      'ownerId': instance.ownerId,
      'phoneNo': instance.phoneNo,
      'pushNotificationToken': instance.pushNotificationToken,
      'searchData': instance.searchData,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
      'userImage': instance.userImage,
      'username': instance.username,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
