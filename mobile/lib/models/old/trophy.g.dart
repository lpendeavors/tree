// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trophy _$TrophyFromJson(Map<String, dynamic> json) {
  return Trophy(
    trophyCount:
        (json['trophyCount'] as List)?.map((e) => e as String)?.toList(),
    trophyIcon: json['trophyIcon'] as String,
    trophyInfo: json['trophyInfo'] as String,
    trophyKey: json['trophyKey'] as String,
    trophyUnlockAt: json['trophyUnlockAt'] as int,
    trophyUnlocked: json['trophyUnlocked'] as bool,
    trophyWon: json['trophyWon'] as bool,
  );
}

Map<String, dynamic> _$TrophyToJson(Trophy instance) => <String, dynamic>{
      'trophyCount': instance.trophyCount,
      'trophyIcon': instance.trophyIcon,
      'trophyInfo': instance.trophyInfo,
      'trophyKey': instance.trophyKey,
      'trophyUnlockAt': instance.trophyUnlockAt,
      'trophyUnlocked': instance.trophyUnlocked,
      'trophyWon': instance.trophyWon,
    };
