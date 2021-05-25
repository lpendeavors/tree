// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostData _$PostDataFromJson(Map<String, dynamic> json) {
  return PostData(
    assetFile: json['assetFile'] as String,
    assetType: json['assetType'] as int,
    docId: json['docId'] as String,
    imagePath: json['imagePath'] as String,
    imageUrl: json['imageUrl'] as String,
    thumbUrl: json['thumbUrl'] as String,
    type: json['type'] as int,
  );
}

Map<String, dynamic> _$PostDataToJson(PostData instance) => <String, dynamic>{
      'assetFile': instance.assetFile,
      'assetType': instance.assetType,
      'docId': instance.docId,
      'imagePath': instance.imagePath,
      'imageUrl': instance.imageUrl,
      'thumbUrl': instance.thumbUrl,
      'type': instance.type,
    };
