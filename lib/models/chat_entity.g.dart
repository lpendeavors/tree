// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatEntity _$ChatEntityFromJson(Map<String, dynamic> json) {
  return ChatEntity(
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
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
    documentId: json['documentId'] as String,
    time: json['time'] as int,
    email: json['email'] as String,
    country: json['country'] as String,
    image: json['image'] as String,
    ownerId: json['ownerId'] as String,
    tokenID: json['tokenID'] as String,
    username: json['username'] as String,
    isAdmin: json['isAdmin'] as bool,
    uid: json['uid'] as String,
    message: json['message'] as String,
    docId: json['docId'] as String,
    type: json['type'] as int,
    parties: (json['parties'] as List)?.map((e) => e as String)?.toList(),
    gender: json['gender'] as int,
    searchData: (json['searchData'] as List)?.map((e) => e as String)?.toList(),
    chatId: json['chatId'] as String,
    isRoom: json['isRoom'] as bool,
    readBy: (json['readBy'] as List)?.map((e) => e as String)?.toList(),
    showDate: json['showDate'] as bool,
  );
}

Map<String, dynamic> _$ChatEntityToJson(ChatEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'isAdmin': instance.isAdmin,
      'chatId': instance.chatId,
      'churchName': instance.churchName,
      'country': instance.country,
      'databaseName': instance.databaseName,
      'docId': instance.docId,
      'email': instance.email,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isRoom': instance.isRoom,
      'isVerified': instance.isVerified,
      'message': instance.message,
      'ownerId': instance.ownerId,
      'parties': instance.parties,
      'phoneNo': instance.phoneNo,
      'pushNotificationToken': instance.pushNotificationToken,
      'readBy': instance.readBy,
      'searchData': instance.searchData,
      'showDate': instance.showDate,
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
