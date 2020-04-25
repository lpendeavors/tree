// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerData _$OwnerDataFromJson(Map<String, dynamic> json) {
  return OwnerData(
    name: json['name'] as String,
    photo: json['photo'] as String,
    uid: json['uid'] as String,
  );
}

Map<String, dynamic> _$OwnerDataToJson(OwnerData instance) => <String, dynamic>{
      'name': instance.name,
      'photo': instance.photo,
      'uid': instance.uid,
    };
