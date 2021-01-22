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
  final List<String> answerResponse;

  const PollData({
    this.answerPosition,
    this.answerTitle,
    this.isAnswer,
    this.label,
    this.answerResponse,
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
      answerResponse,
    ];
  }

  @override
  bool get stringify => true;
}
