// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preview_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreviewEntity _$UserPreviewEntityFromJson(Map<String, dynamic> json) {
  return UserPreviewEntity(
    documentId: json['documentId'] as String,
    uid: json['uid'] as String,
    image: json['image'] as String,
    isChurch: json['isChurch'] as bool,
    fullName: json['fullName'] as String,
    churchName: json['churchName'] as String,
    aboutMe: json['aboutMe'] as String,
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
  );
}

Map<String, dynamic> _$UserPreviewEntityToJson(UserPreviewEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'uid': instance.uid,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'fullName': instance.fullName,
      'churchName': instance.churchName,
      'aboutMe': instance.aboutMe,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
