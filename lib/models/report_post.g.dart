// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportPost _$ReportPostFromJson(Map<String, dynamic> json) {
  return ReportPost(
    tokenID: json['tokenID'] as String,
    isChurch: json['isChurch'] as bool,
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    byAdmin: json['byAdmin'] as bool,
    churchName: json['churchName'] as String,
    country: json['country'] as String,
    databaseName: json['databaseName'] as String,
    fullName: json['fullName'] as String,
    ownerId: json['ownerId'] as String,
    phoneNo: json['phoneNo'] as String,
    timeUpdated: json['timeUpdated'] as int,
    username: json['username'] as String,
    userImage: json['userImage'] as String,
    visibility: json['visibility'] as int,
    docId: json['docId'] as String,
    time: json['time'] as int,
    uid: json['uid'] as String,
    email: json['email'] as String,
    image: json['image'] as String,
    gender: json['gender'] as int,
    postMessage: json['postMessage'] as String,
    parties: (json['parties'] as List)?.map((e) => e as String)?.toList(),
    isReported: json['isReported'] as bool,
    isHostPrivate: json['isHostPrivate'] as int,
    fileUploaded: json['fileUploaded'] as bool,
    fileToUpload:
        (json['fileToUpload'] as List)?.map((e) => e as String)?.toList(),
    type: json['type'] as int,
    isAdmin: json['isAdmin'] as bool,
    isHidden: json['isHidden'] as bool,
    tags: (json['tags'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ReportPostToJson(ReportPost instance) =>
    <String, dynamic>{
      'byAdmin': instance.byAdmin,
      'churchName': instance.churchName,
      'country': instance.country,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'email': instance.email,
      'fileToUpload': instance.fileToUpload,
      'fileUploaded': instance.fileUploaded,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isAdmin': instance.isAdmin,
      'isChurch': instance.isChurch,
      'isHidden': instance.isHidden,
      'isHostPrivate': instance.isHostPrivate,
      'isReported': instance.isReported,
      'ownerId': instance.ownerId,
      'parties': instance.parties,
      'phoneNo': instance.phoneNo,
      'postMessage': instance.postMessage,
      'tags': instance.tags,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'tokenID': instance.tokenID,
      'type': instance.type,
      'uid': instance.uid,
      'userImage': instance.userImage,
      'username': instance.username,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
