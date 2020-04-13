// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_owner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyOwner _$ReplyOwnerFromJson(Map<String, dynamic> json) {
  return ReplyOwner(
    churchInfo: json['churchInfo'] == null
        ? null
        : ChurchInfo.fromJson(json['churchInfo'] as Map<String, dynamic>),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    visibility: json['visibility'] as int,
    databaseName: json['databaseName'] as String,
    time: json['time'] as int,
    tokenID: json['tokenID'] as String,
    title: json['title'] as String,
    docId: json['docId'] as String,
    image: json['image'] as String,
    searchData: (json['searchData'] as List)?.map((e) => e as String)?.toList(),
    pushNotificationToken: json['pushNotificationToken'] as String,
    phoneNo: json['phoneNo'] as String,
    isVerified: json['isVerified'] as bool,
    isChurch: json['isChurch'] as bool,
    fullName: json['fullName'] as String,
    uid: json['uid'] as String,
    email: json['email'] as String,
    isAdmin: json['isAdmin'] as bool,
    status: json['status'] as int,
    trophyCreated: json['trophyCreated'] as bool,
    treeTrophies: (json['treeTrophies'] as List)
        ?.map((e) =>
            e == null ? null : Trophy.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    timeOnline: json['timeOnline'] as int,
    signUpComplete: json['signUpComplete'] as bool,
    phoneVerified: json['phoneVerified'] as bool,
    newApp1: json['newApp1'] as bool,
    lastName: json['lastName'] as String,
    isPublic: json['isPublic'] as bool,
    isOnline1: json['isOnline1'] as int,
    firstName: json['firstName'] as String,
    password: json['password'] as String,
    aboutMe: json['aboutMe'] as String,
    attending: (json['attending'] as List)?.map((e) => e as String)?.toList(),
    businessAddress: json['businessAddress'] as String,
    chuchVerified: json['chuchVerified'] as bool,
    churchId: json['churchId'] as String,
    churchNotFound: json['churchNotFound'] as bool,
    city: json['city'] as String,
    connections:
        (json['connections'] as List)?.map((e) => e as String)?.toList(),
    hasChurch: json['hasChurch'] as bool,
    isChurchUpdated: json['isChurchUpdated'] as bool,
    isPersonalUpdated: json['isPersonalUpdated'] as bool,
    isTyping: json['isTyping'] as bool,
    myChatsList13: (json['myChatsList13'] as List)
        ?.map((e) =>
            e == null ? null : ReplyChat.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    myConnect: json['myConnect'] as bool,
    receivedRequests:
        (json['receivedRequests'] as List)?.map((e) => e as String)?.toList(),
    recentSearch: (json['recentSearch'] as List)
        ?.map((e) =>
            e == null ? null : ReplySearch.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    relationStatus: json['relationStatus'] as String,
    typing: json['typing'] as bool,
  );
}

Map<String, dynamic> _$ReplyOwnerToJson(ReplyOwner instance) =>
    <String, dynamic>{
      'aboutMe': instance.aboutMe,
      'attending': instance.attending,
      'businessAddress': instance.businessAddress,
      'churchId': instance.churchId,
      'churchInfo': instance.churchInfo?.toJson(),
      'churchNotFound': instance.churchNotFound,
      'chuchVerified': instance.chuchVerified,
      'city': instance.city,
      'connections': instance.connections,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'email': instance.email,
      'firstName': instance.firstName,
      'fullName': instance.fullName,
      'hasChurch': instance.hasChurch,
      'image': instance.image,
      'isAdmin': instance.isAdmin,
      'isChurch': instance.isChurch,
      'isChurchUpdated': instance.isChurchUpdated,
      'isOnline1': instance.isOnline1,
      'isPersonalUpdated': instance.isPersonalUpdated,
      'isPublic': instance.isPublic,
      'isTyping': instance.isTyping,
      'isVerified': instance.isVerified,
      'lastName': instance.lastName,
      'myChatsList13':
          instance.myChatsList13?.map((e) => e?.toJson())?.toList(),
      'myConnect': instance.myConnect,
      'newApp1': instance.newApp1,
      'password': instance.password,
      'phoneNo': instance.phoneNo,
      'phoneVerified': instance.phoneVerified,
      'pushNotificationToken': instance.pushNotificationToken,
      'receivedRequests': instance.receivedRequests,
      'recentSearch': instance.recentSearch?.map((e) => e?.toJson())?.toList(),
      'relationStatus': instance.relationStatus,
      'searchData': instance.searchData,
      'signUpComplete': instance.signUpComplete,
      'status': instance.status,
      'time': instance.time,
      'timeOnline': instance.timeOnline,
      'title': instance.title,
      'tokenID': instance.tokenID,
      'treeTrophies': instance.treeTrophies?.map((e) => e?.toJson())?.toList(),
      'trophyCreated': instance.trophyCreated,
      'typing': instance.typing,
      'uid': instance.uid,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
