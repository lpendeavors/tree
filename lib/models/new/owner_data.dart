import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'owner_data.g.dart';

@immutable
@JsonSerializable()
class OwnerData extends Equatable {
  final String name;
  final String photo;
  final String uid;

  const OwnerData({
    this.name,
    this.photo,
    this.uid
  });

  factory OwnerData.fromJson(Map<String, dynamic> json) => _$OwnerDataFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerDataToJson(this);

  @override
  List get props {
    return [
      name,
      photo,
      uid
    ];
  }

  @override
  bool get stringify => true;
}