// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferenceEntity _$ReferenceEntityFromJson(Map<String, dynamic> json) {
  return ReferenceEntity(
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    documentId: json['documentId'] as String,
    timeUpdated: json['timeUpdated'] as int,
    databaseName: json['databaseName'] as String,
    visibility: json['visibility'] as int,
    time: json['time'] as int,
    fileUrl: json['fileUrl'] as String,
    reference: json['reference'] as String,
  );
}

Map<String, dynamic> _$ReferenceEntityToJson(ReferenceEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'databaseName': instance.databaseName,
      'fileUrl': instance.fileUrl,
      'reference': instance.reference,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
