import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'church_info.g.dart';

@immutable
@JsonSerializable()
class ChurchInfo extends Equatable {
  final String churchName;
  final String churchAddress;
  final String churchDenomination;

  const ChurchInfo({
    this.churchName,
    this.churchAddress,
    this.churchDenomination,
  });

  factory ChurchInfo.fromJson(Map<String, dynamic> json) => _$ChurchInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChurchInfoToJson(this);

  @override
  List get props {
    return [
      churchName,
      churchAddress,
      churchDenomination,
    ];
  }

  @override
  bool get stringify => true;
}