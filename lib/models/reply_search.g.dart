// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplySearch _$ReplySearchFromJson(Map<String, dynamic> json) {
  return ReplySearch(
    churchInfo: json['churchInfo'] == null
        ? null
        : ChurchInfo.fromJson(json['churchInfo'] as Map<String, dynamic>),
    pushNotificationToken: json['pushNotificationToken'] as String,
    isChurch: json['isChurch'] as bool,
    fullName: json['fullName'] as String,
    docId: json['docId'] as String,
    image: json['image'] as String,
    uid: json['uid'] as String,
    city: json['city'] as String,
    time: json['time'] as int,
    type: json['type'] as int,
    personId: json['personId'] as String,
  );
}

Map<String, dynamic> _$ReplySearchToJson(ReplySearch instance) =>
    <String, dynamic>{
      'churchInfo': instance.churchInfo?.toJson(),
      'city': instance.city,
      'docId': instance.docId,
      'fullName': instance.fullName,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'personId': instance.personId,
      'pushNotificationToken': instance.pushNotificationToken,
      'time': instance.time,
      'type': instance.type,
      'uid': instance.uid,
    };
