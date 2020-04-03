// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) {
  return UserEntity(
    documentId: json['documentId'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    createdAt: timestampFromJson(json['created_at'] as Timestamp),
    updatedAt: timestampFromJson(json['updated_at'] as Timestamp),
  );
}

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'email': instance.email,
      'full_name': instance.fullName,
      'created_at': timestampToJson(instance.createdAt),
      'updated_at': timestampToJson(instance.updatedAt),
    };
