// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollData _$PollDataFromJson(Map<String, dynamic> json) {
  return PollData(
    answerPosition: json['answerPosition'] as int,
    answerTitle: json['answerTitle'] as String,
    isAnswer: json['isAnswer'] as bool,
    label: json['label'] as String,
    answerResponse:
        (json['answerResponse'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$PollDataToJson(PollData instance) => <String, dynamic>{
      'answerPosition': instance.answerPosition,
      'answerTitle': instance.answerTitle,
      'isAnswer': instance.isAnswer,
      'label': instance.label,
      'answerResponse': instance.answerResponse,
    };
