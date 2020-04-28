// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventEntity _$EventEntityFromJson(Map<String, dynamic> json) {
  return EventEntity(
    documentId: json['documentId'] as String,
    assets: (json['assets'] as List)
        ?.map((e) =>
            e == null ? null : AssetData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    description: json['description'] as String,
    global: json['global'] as bool,
    location: json['location'] == null
        ? null
        : LocationData.fromJson(json['location'] as Map<String, dynamic>),
    owner: json['owner'] == null
        ? null
        : OwnerData.fromJson(json['owner'] as Map<String, dynamic>),
    title: json['title'] as String,
    type: json['type'] as int,
    startDate: timestampFromJson(json['startDate'] as Timestamp),
    endDate: timestampFromJson(json['endDate'] as Timestamp),
  );
}

Map<String, dynamic> _$EventEntityToJson(EventEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'assets': instance.assets?.map((e) => e?.toJson())?.toList(),
      'description': instance.description,
      'global': instance.global,
      'location': instance.location?.toJson(),
      'owner': instance.owner?.toJson(),
      'title': instance.title,
      'type': instance.type,
      'startDate': timestampToJson(instance.startDate),
      'endDate': timestampToJson(instance.endDate),
    };
