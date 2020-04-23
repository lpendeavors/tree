import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

@immutable
@JsonSerializable()
class AssetData extends Equatable {
  final String url;
  final int type;

  const AssetData({
    this.url,
    this.type
  });

  factory AssetData.fromJson(Map<String, dynamic> json) => _$AssetDataFromJson(json);
  Map<String, dynamic> toJson() => _$AssetDataToJson(this);

  @override
  List get props {
    return [
      url,
      type
    ];
  }

  @override
  bool get stringify => true;
}