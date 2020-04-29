// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) {
  return UserEntity(
    documentId: json['documentId'] as String,
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    firstName: json['firstName'] as String,
    isChurch: json['isChurch'] as bool,
    isOnline1: json['isOnline1'] as int,
    isPublic: json['isPublic'] as bool,
    lastName: json['lastName'] as String,
    newApp1: json['newApp1'] as bool,
    password: json['password'] as String,
    phoneNumber: json['phoneNumber'] as String,
    phoneVerified: json['phoneVerified'] as bool,
    pushNotificationToken: json['pushNotificationToken'] as String,
    searchData: (json['searchData'] as List)?.map((e) => e as String)?.toList(),
    signUpComplete: json['signUpComplete'] as bool,
    time: json['time'] as int,
    timeOnline: json['timeOnline'] as int,
    timeUpdated: json['timeUpdated'] as int,
    tokenID: json['tokenID'] as String,
    treeTrophies: (json['treeTrophies'] as List)
        ?.map((e) =>
            e == null ? null : Trophy.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    trophyCreated: json['trophyCreated'] as bool,
    uid: json['uid'] as String,
    visibility: json['visibility'] as int,
  );
}

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'isChurch': instance.isChurch,
      'isOnline1': instance.isOnline1,
      'isPublic': instance.isPublic,
      'newApp1': instance.newApp1,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'phoneVerified': instance.phoneVerified,
      'pushNotificationToken': instance.pushNotificationToken,
      'searchData': instance.searchData,
      'signUpComplete': instance.signUpComplete,
      'tokenID': instance.tokenID,
      'treeTrophies': instance.treeTrophies?.map((e) => e?.toJson())?.toList(),
      'trophyCreated': instance.trophyCreated,
      'uid': instance.uid,
      'visibility': instance.visibility,
      'time': instance.time,
      'timeOnline': instance.timeOnline,
      'timeUpdated': instance.timeUpdated,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
