// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentEntity _$CommentEntityFromJson(Map<String, dynamic> json) {
  return CommentEntity(
    documentId: json['documentId'] as String,
    uid: json['uid'] as String,
    isAdmin: json['isAdmin'] as bool,
    username: json['username'] as String,
    visibility: json['visibility'] as int,
    userImage: json['userImage'] as String,
    tokenID: json['tokenID'] as String,
    pushNotificationToken: json['pushNotificationToken'] as String,
    postMessage: json['postMessage'] as String,
    phoneNo: json['phoneNo'] as String,
    ownerId: json['ownerId'] as String,
    isVerified: json['isVerified'] as bool,
    isChurch: json['isChurch'] as bool,
    image: json['image'] as String,
    gender: json['gender'] as int,
    fullName: json['fullName'] as String,
    databaseName: json['databaseName'] as String,
    country: json['country'] as String,
    churchName: json['churchName'] as String,
    email: json['email'] as String,
    timeUpdated: json['timeUpdated'] as int,
    time: json['time'] as int,
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    likes: (json['likes'] as List)?.map((e) => e as String)?.toList(),
    postId: json['postId'] as String,
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    isGIF: json['isGIF'] as bool,
    imagePath: json['imagePath'] as String,
  );
}

Map<String, dynamic> _$CommentEntityToJson(CommentEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'isAdmin': instance.isAdmin,
      'churchName': instance.churchName,
      'country': instance.country,
      'databaseName': instance.databaseName,
      'email': instance.email,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isVerified': instance.isVerified,
      'likes': instance.likes,
      'ownerId': instance.ownerId,
      'phoneNo': instance.phoneNo,
      'postId': instance.postId,
      'postMessage': instance.postMessage,
      'pushNotificationToken': instance.pushNotificationToken,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
      'userImage': instance.userImage,
      'username': instance.username,
      'visibility': instance.visibility,
      'isGIF': instance.isGIF,
      'imagePath': instance.imagePath,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
