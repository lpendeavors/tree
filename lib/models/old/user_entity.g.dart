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
    phoneNo: json['phoneNo'] as String,
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
    image: json['image'] as String,
    visibility: json['visibility'] as int,
    myChatsList13: (json['myChatsList13'] as List)
        ?.map((e) =>
            e == null ? null : ChatData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    receivedRequests:
        (json['receivedRequests'] as List)?.map((e) => e as String)?.toList(),
    sentRequests:
        (json['sentRequests'] as List)?.map((e) => e as String)?.toList(),
    churchInfo: json['churchInfo'] == null
        ? null
        : ChurchInfo.fromJson(json['churchInfo'] as Map<String, dynamic>),
    churchName: json['churchName'] as String,
    isVerified: json['isVerified'] as bool,
    connections:
        (json['connections'] as List)?.map((e) => e as String)?.toList(),
    shares: (json['shares'] as List)?.map((e) => e as String)?.toList(),
    type: json['type'] as int,
    churchDenomination: json['churchDenomination'] as String,
    churchAddress: json['churchAddress'] as String,
    aboutMe: json['aboutMe'] as String,
    title: json['title'] as String,
    city: json['city'] as String,
    relationStatus: json['relationStatus'] as String,
    chatNotification: json['chatNotification'] as bool,
    chatOnlineStatus: json['chatOnlineStatus'] as bool,
    groupNotification: json['groupNotification'] as bool,
    messageNotification: json['messageNotification'] as bool,
    isAdmin: json['isAdmin'] as bool,
    businessAddress: json['businessAddress'] as String,
    status: json['status'] as int,
    churchWebsite: json['churchWebsite'] as String,
    parentChurch: json['parentChurch'] as String,
    churchLat: (json['churchLat'] as num)?.toDouble(),
    churchLong: (json['churchLong'] as num)?.toDouble(),
    isChurchUpdated: json['isChurchUpdated'] as bool,
    isProfileUpdated: json['isProfileUpdated'] as bool,
  );
}

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'churchName': instance.churchName,
      'isChurch': instance.isChurch,
      'isVerified': instance.isVerified,
      'isOnline1': instance.isOnline1,
      'isPublic': instance.isPublic,
      'newApp1': instance.newApp1,
      'password': instance.password,
      'phoneNo': instance.phoneNo,
      'phoneVerified': instance.phoneVerified,
      'pushNotificationToken': instance.pushNotificationToken,
      'searchData': instance.searchData,
      'signUpComplete': instance.signUpComplete,
      'tokenID': instance.tokenID,
      'treeTrophies': instance.treeTrophies?.map((e) => e?.toJson())?.toList(),
      'trophyCreated': instance.trophyCreated,
      'uid': instance.uid,
      'image': instance.image,
      'visibility': instance.visibility,
      'time': instance.time,
      'timeOnline': instance.timeOnline,
      'timeUpdated': instance.timeUpdated,
      'myChatsList13':
          instance.myChatsList13?.map((e) => e?.toJson())?.toList(),
      'receivedRequests': instance.receivedRequests,
      'sentRequests': instance.sentRequests,
      'churchInfo': instance.churchInfo?.toJson(),
      'connections': instance.connections,
      'shares': instance.shares,
      'type': instance.type,
      'churchDenomination': instance.churchDenomination,
      'churchAddress': instance.churchAddress,
      'aboutMe': instance.aboutMe,
      'title': instance.title,
      'city': instance.city,
      'relationStatus': instance.relationStatus,
      'chatNotification': instance.chatNotification,
      'chatOnlineStatus': instance.chatOnlineStatus,
      'groupNotification': instance.groupNotification,
      'messageNotification': instance.messageNotification,
      'isAdmin': instance.isAdmin,
      'businessAddress': instance.businessAddress,
      'status': instance.status,
      'churchWebsite': instance.churchWebsite,
      'parentChurch': instance.parentChurch,
      'churchLat': instance.churchLat,
      'churchLong': instance.churchLong,
      'isChurchUpdated': instance.isChurchUpdated,
      'isProfileUpdated': instance.isProfileUpdated,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
