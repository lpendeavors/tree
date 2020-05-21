// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberEntity _$MemberEntityFromJson(Map<String, dynamic> json) {
  return MemberEntity(
    uid: json['uid'] as String,
    name: json['name'] as String,
    photo: json['photo'] as String,
    room: json['room'] as String,
  );
}

Map<String, dynamic> _$MemberEntityToJson(MemberEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'photo': instance.photo,
      'room': instance.room,
    };
