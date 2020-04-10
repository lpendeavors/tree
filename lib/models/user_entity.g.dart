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
    searchData: (json['searchData'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
    signUpComplete: json['signUpComplete'] as bool,
    time: timestampFromJson(json['time'] as Timestamp),
    timeOnline: timestampFromJson(json['timeOnline'] as Timestamp),
    timeUpdated: timestampFromJson(json['timeUpdated'] as Timestamp),
    tokenID: json['tokenID'] as String,
    treeTrophies: json['treeTrophies'] as List,
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
      'searchData': instance.searchData
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList(),
      'signUpComplete': instance.signUpComplete,
      'tokenID': instance.tokenID,
      'treeTrophies': instance.treeTrophies,
      'trophyCreated': instance.trophyCreated,
      'uid': instance.uid,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
      'time': timestampToJson(instance.time),
      'timeOnline': timestampToJson(instance.timeOnline),
      'timeUpdated': timestampToJson(instance.timeUpdated),
    };
