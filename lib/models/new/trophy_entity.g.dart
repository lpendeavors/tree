// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrophyEntity _$TrophyEntityFromJson(Map<String, dynamic> json) {
  return TrophyEntity(
    documentId: json['documentId'] as String,
    icon: json['icon'] as String,
    key: json['key'] as String,
    title: json['title'] as String,
    value: json['value'] as int,
  );
}

Map<String, dynamic> _$TrophyEntityToJson(TrophyEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'icon': instance.icon,
      'key': instance.key,
      'title': instance.title,
      'value': instance.value,
    };
