import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'poll_data.g.dart';

@immutable
@JsonSerializable()
class PollData extends Equatable {
  final int answerPosition;
  final String answerTitle;
  final bool isAnswer;
  final String label;

  const PollData({
    this.answerPosition,
    this.answerTitle,
    this.isAnswer,
    this.label,
  });

  factory PollData.fromJson(Map<String, dynamic> json) =>
      _$PollDataFromJson(json);
  Map<String, dynamic> toJson() => _$PollDataToJson(this);

  @override
  List get props {
    return [
      answerPosition,
      answerTitle,
      isAnswer,
      label,
    ];
  }

  @override
  bool get stringify => true;
}
