// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostEntity _$PostEntityFromJson(Map<String, dynamic> json) {
  return PostEntity(
    documentId: json['documentId'] as String,
    date: timestampFromJson(json['date'] as Timestamp),
    edited: timestampFromJson(json['edited'] as Timestamp),
    body: json['body'] as String,
    global: json['global'] as bool,
    likes: (json['likes'] as List)?.map((e) => e as String)?.toList(),
    tags: (json['tags'] as List)?.map((e) => e as String)?.toList(),
    owner: json['owner'] == null
        ? null
        : OwnerData.fromJson(json['owner'] as Map<String, dynamic>),
    assets: (json['assets'] as List)
        ?.map((e) =>
            e == null ? null : AssetData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PostEntityToJson(PostEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'body': instance.body,
      'global': instance.global,
      'likes': instance.likes,
      'tags': instance.tags,
      'owner': instance.owner?.toJson(),
      'assets': instance.assets?.map((e) => e?.toJson())?.toList(),
      'date': timestampToJson(instance.date),
      'edited': timestampToJson(instance.edited),
    };
