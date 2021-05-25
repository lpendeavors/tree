import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'post_data.g.dart';

@immutable
@JsonSerializable()
class PostData extends Equatable {
  final String assetFile;
  final int assetType;
  final String docId;
  final String imagePath;
  final String imageUrl;
  final String thumbUrl;
  final int type;

  const PostData({
    this.assetFile,
    this.assetType,
    this.docId,
    this.imagePath,
    this.imageUrl,
    this.thumbUrl,
    this.type,
  });

  factory PostData.fromJson(Map<String, dynamic> json) => _$PostDataFromJson(json);
  Map<String, dynamic> toJson() => _$PostDataToJson(this);

  @override
  List get props {
    return [
      assetFile,
      assetType,
      docId,
      imagePath,
      imageUrl,
      thumbUrl,
      type,
    ];
  }

  @override
  bool get stringify => true;
}