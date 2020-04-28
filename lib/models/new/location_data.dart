import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'location_data.g.dart';

@immutable
@JsonSerializable()
class LocationData extends Equatable {
  final String address;
  final int lat;
  final int long;

  const LocationData({
    this.address,
    this.lat,
    this.long
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  @override
  List get props {
    return [
      address,
      lat,
      long
    ];
  }

  @override
  bool get stringify => true;
}