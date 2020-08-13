// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentReply _$CommentReplyFromJson(Map<String, dynamic> json) {
  return CommentReply(
    byAdmin: json['byAdmin'] as bool,
    churchName: json['churchName'] as String,
    country: json['country'] as String,
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    gender: json['gender'] as int,
    image: json['image'] as String,
    isChurch: json['isChurch'] as bool,
    isVerified: json['isVerified'] as bool,
    ownerId: json['ownerId'] as String,
    postId: json['postId'] as String,
    postMessage: json['postMessage'] as String,
    pushNotificationToken: json['pushNotificationToken'] as String,
    time: json['time'] as int,
    timeUpdated: json['timeUpdated'] as int,
    tokenID: json['tokenID'] as String,
    uid: json['uid'] as String,
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    userImage: json['userImage'] as String,
    username: json['username'] as String,
    visibility: json['visibility'] as int,
    imagePath: json['imagePath'] as String,
    isGIF: json['isGIF'] as bool,
  );
}

Map<String, dynamic> _$CommentReplyToJson(CommentReply instance) =>
    <String, dynamic>{
      'byAdmin': instance.byAdmin,
      'churchName': instance.churchName,
      'country': instance.country,
      'email': instance.email,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isVerified': instance.isVerified,
      'ownerId': instance.ownerId,
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
      'imagePath': instance.imagePath,
      'isGIF': instance.isGIF,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
