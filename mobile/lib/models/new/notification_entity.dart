import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';

part 'notification_entity.g.dart';

@immutable
@JsonSerializable()
class NotificationEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String body;
  final bool global;
  final List<String> readBy;
  final String title;
  final String tokenID;
  final int type;
  final String sender;
  final String image;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp date;

  const NotificationEntity({
    this.documentId,
    this.body,
    this.global,
    this.readBy,
    this.title,
    this.tokenID,
    this.type,
    this.sender,
    this.image,
    this.date
  });

  String get id => this.documentId;

  factory NotificationEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$NotificationEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$NotificationEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      body,
      global,
      readBy,
      title,
      tokenID,
      type,
      sender,
      image,
      date
    ];
  }

  @override get stringify => true;
}