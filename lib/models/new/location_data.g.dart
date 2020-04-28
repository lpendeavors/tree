// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationData _$LocationDataFromJson(Map<String, dynamic> json) {
  return LocationData(
    address: json['address'] as String,
    lat: json['lat'] as int,
    long: json['long'] as int,
  );
}

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'address': instance.address,
      'lat': instance.lat,
      'long': instance.long,
    };
