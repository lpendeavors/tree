// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetData _$AssetDataFromJson(Map<String, dynamic> json) {
  return AssetData(
    url: json['url'] as String,
    type: json['type'] as int,
  );
}

Map<String, dynamic> _$AssetDataToJson(AssetData instance) => <String, dynamic>{
      'url': instance.url,
      'type': instance.type,
    };
