// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) {
  return UserEntity(
    documentId: json['documentId'] as String,
    church: json['church'] as bool,
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    phone: json['phone'] as String,
    photo: json['photo'] as String,
    private: json['private'] as bool,
    trophies: (json['trophies'] as List)?.map((e) => e as String)?.toList(),
    joined: timestampFromJson(json['joined'] as Timestamp),
  );
}

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'church': instance.church,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'photo': instance.photo,
      'private': instance.private,
      'trophies': instance.trophies,
      'joined': timestampToJson(instance.joined),
    };
