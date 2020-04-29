import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'church_info.dart';

part 'reply_search.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class ReplySearch extends Equatable {
  final ChurchInfo churchInfo;
  final String city;
  final String docId;
  final String fullName;
  final String image;
  final bool isChurch;
  final String personId;
  final String pushNotificationToken;
  final int time;
  final int type;
  final String uid;

  const ReplySearch({
    this.churchInfo,
    this.pushNotificationToken,
    this.isChurch,
    this.fullName,
    this.docId,
    this.image,
    this.uid,
    this.city,
    this.time,
    this.type,
    this.personId,
  });

  factory ReplySearch.fromJson(Map<String, dynamic> json) => _$ReplySearchFromJson(json);
  Map<String, dynamic> toJson() => _$ReplySearchToJson(this);

  @override
  List get props {
    return [
      churchInfo,
      pushNotificationToken,
      isChurch,
      fullName,
      docId,
      image,
      uid,
      city,
      time,
      type,
      personId,
    ];
  }

  @override
  bool get stringify => true;
}