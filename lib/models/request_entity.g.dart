// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestEntity _$RequestEntityFromJson(Map<String, dynamic> json) {
  return RequestEntity(
    churchInfo: json['churchInfo'] == null
        ? null
        : ChurchInfo.fromJson(json['churchInfo'] as Map<String, dynamic>),
    visibility: json['visibility'] as int,
    userImage: json['userImage'] as String,
    username: json['username'] as String,
    timeUpdated: json['timeUpdated'] as int,
    phoneNo: json['phoneNo'] as String,
    ownerId: json['ownerId'] as String,
    fullName: json['fullName'] as String,
    databaseName: json['databaseName'] as String,
    country: json['country'] as String,
    churchName: json['churchName'] as String,
    byAdmin: json['byAdmin'] as bool,
    gender: json['gender'] as int,
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    isChurch: json['isChurch'] as bool,
    image: json['image'] as String,
    documentId: json['documentId'] as String,
    email: json['email'] as String,
    tokenID: json['tokenID'] as String,
    uid: json['uid'] as String,
    time: json['time'] as int,
    personId: json['personId'] as String,
    docId: json['docId'] as String,
    pushNotificationToken: json['pushNotificationToken'] as String,
    city: json['city'] as String,
    isVerified: json['isVerified'] as bool,
  );
}

Map<String, dynamic> _$RequestEntityToJson(RequestEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'byAdmin': instance.byAdmin,
      'churchInfo': instance.churchInfo?.toJson(),
      'churchName': instance.churchName,
      'city': instance.city,
      'country': instance.country,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'email': instance.email,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isVerified': instance.isVerified,
      'ownerId': instance.ownerId,
      'personId': instance.personId,
      'phoneNo': instance.phoneNo,
      'pushNotificationToken': instance.pushNotificationToken,
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
