// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestEntity _$RequestEntityFromJson(Map<String, dynamic> json) {
  return RequestEntity(
    documentId: json['documentId'] as String,
    from: json['from'] as String,
    to: json['to'] as String,
    date: timestampFromJson(json['date'] as Timestamp),
  );
}

Map<String, dynamic> _$RequestEntityToJson(RequestEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'from': instance.from,
      'to': instance.to,
      'date': timestampToJson(instance.date),
    };
