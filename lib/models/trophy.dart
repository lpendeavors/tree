import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'trophy.g.dart';

@immutable
@JsonSerializable()
class Trophy extends Equatable {
  final List<String> trophyCount;
  final String trophyIcon;
  final String trophyInfo;
  final String trophyKey;
  final int trophyUnlockAt;
  final bool trophyUnlocked;
  final bool trophyWon;

  const Trophy({
    this.trophyCount,
    this.trophyIcon,
    this.trophyInfo,
    this.trophyKey,
    this.trophyUnlockAt,
    this.trophyUnlocked,
    this.trophyWon,
  });

  factory Trophy.fromJson(Map<String, dynamic> json) => _$TrophyFromJson(json);
  Map<String, dynamic> toJson() => _$TrophyToJson(this);

  @override
  List<Object> get props {
    return [
      trophyCount,
      trophyIcon,
      trophyInfo,
      trophyKey,
      trophyUnlockAt,
      trophyUnlocked,
      trophyWon,
    ];
  }

  @override
  bool get stringify => true;
}