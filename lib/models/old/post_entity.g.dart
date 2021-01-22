// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostEntity _$PostEntityFromJson(Map<String, dynamic> json) {
  return PostEntity(
    documentId: json['documentId'] as String,
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    visibility: json['visibility'] as int,
    tokenID: json['tokenID'] as String,
    pushNotificationToken: json['pushNotificationToken'] as String,
    isChurch: json['isChurch'] as bool,
    uid: json['uid'] as String,
    byAdmin: json['byAdmin'] as bool,
    churchName: json['churchName'] as String,
    country: json['country'] as String,
    databaseName: json['databaseName'] as String,
    docId: json['docId'] as String,
    email: json['email'] as String,
    fileUploaded: json['fileUploaded'] as bool,
    fullName: json['fullName'] as String,
    gender: json['gender'] as int,
    image: json['image'] as String,
    isAdmin: json['isAdmin'] as bool,
    isGroup: json['isGroup'] as bool,
    isHidden: json['isHidden'] as bool,
    isPostPrivate: json['isPostPrivate'] as int,
    isReported: json['isReported'] as bool,
    isVerified: json['isVerified'] as bool,
    ownerId: json['ownerId'] as String,
    parties: (json['parties'] as List)?.map((e) => e as String)?.toList(),
    phoneNo: json['phoneNo'] as String,
    pollData: (json['pollData'] as List)
        ?.map((e) =>
            e == null ? null : PollData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    postData: (json['postData'] as List)
        ?.map((e) =>
            e == null ? null : PostData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    postMessage: json['postMessage'] as String,
    tags: (json['tags'] as List)?.map((e) => e as String)?.toList(),
    type: json['type'] as int,
    userImage: json['userImage'] as String,
    username: json['username'] as String,
    time: json['time'] as int,
    likes: (json['likes'] as List)?.map((e) => e as String)?.toList(),
    muted: (json['muted'] as List)?.map((e) => e as String)?.toList(),
    pollDuration:
        (json['pollDuration'] as List)?.map((e) => e as int)?.toList(),
    sharedPost: json['sharedPost'] == null
        ? null
        : SharedPost.fromJson(json['sharedPost'] as Map<String, dynamic>),
    isShared: json['isShared'] as bool,
  );
}

Map<String, dynamic> _$PostEntityToJson(PostEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'byAdmin': instance.byAdmin,
      'churchName': instance.churchName,
      'country': instance.country,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'email': instance.email,
      'fileUploaded': instance.fileUploaded,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isAdmin': instance.isAdmin,
      'isChurch': instance.isChurch,
      'isGroup': instance.isGroup,
      'isHidden': instance.isHidden,
      'isPostPrivate': instance.isPostPrivate,
      'isReported': instance.isReported,
      'isVerified': instance.isVerified,
      'ownerId': instance.ownerId,
      'parties': instance.parties,
      'phoneNo': instance.phoneNo,
      'postMessage': instance.postMessage,
      'pushNotificationToken': instance.pushNotificationToken,
      'tags': instance.tags,
      'tokenID': instance.tokenID,
      'postData': instance.postData?.map((e) => e?.toJson())?.toList(),
      'pollData': instance.pollData?.map((e) => e?.toJson())?.toList(),
      'type': instance.type,
      'uid': instance.uid,
      'userImage': instance.userImage,
      'username': instance.username,
      'visibility': instance.visibility,
      'time': instance.time,
      'likes': instance.likes,
      'muted': instance.muted,
      'pollDuration': instance.pollDuration,
      'sharedPost': instance.sharedPost?.toJson(),
      'isShared': instance.isShared,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
