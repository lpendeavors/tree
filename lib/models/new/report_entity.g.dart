// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportEntity _$ReportEntityFromJson(Map<String, dynamic> json) {
  return ReportEntity(
    documentId: json['documentId'] as String,
    email: json['email'] as String,
    fromUID: json['fromUID'] as String,
    name: json['name'] as String,
    reason: json['reason'] as String,
    reporting: json['reporting'] as String,
    type: json['type'] as int,
    date: timestampFromJson(json['date'] as Timestamp),
  );
}

Map<String, dynamic> _$ReportEntityToJson(ReportEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'email': instance.email,
      'fromUID': instance.fromUID,
      'name': instance.name,
      'reason': instance.reason,
      'reporting': instance.reporting,
      'type': instance.type,
      'date': timestampToJson(instance.date),
    };
