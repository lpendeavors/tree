// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChurchInfo _$ChurchInfoFromJson(Map<String, dynamic> json) {
  return ChurchInfo(
    churchName: json['churchName'] as String,
    churchAddress: json['churchAddress'] as String,
    churchDenomination: json['churchDenomination'] as String,
  );
}

Map<String, dynamic> _$ChurchInfoToJson(ChurchInfo instance) =>
    <String, dynamic>{
      'churchName': instance.churchName,
      'churchAddress': instance.churchAddress,
      'churchDenomination': instance.churchDenomination,
    };
