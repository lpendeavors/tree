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
  final String databaseName;
  final String docId;
  final String fullName;
  final String image;
  final String message;
  final int notificationType;
  final String ownerId;
  final String postId;
  final List<String> readBy;
  final int status;
  final int time;
  final int timeUpdated;
  final String title;
  final String tokenID;
  final int visibility;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp createdAt;
  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp updatedAt;

  const NotificationEntity({
    this.visibility,
    this.databaseName,
    this.timeUpdated,
    this.documentId,
    this.updatedAt,
    this.tokenID,
    this.fullName,
    this.image,
    this.docId,
    this.time,
    this.readBy,
    this.createdAt,
    this.message,
    this.postId,
    this.title,
    this.body,
    this.notificationType,
    this.ownerId,
    this.status,
  });

  String get id => this.documentId;

  factory NotificationEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$NotificationEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$NotificationEntityToJson(this);

  @override
  List get props {
    return [
      visibility,
      databaseName,
      timeUpdated,
      documentId,
      updatedAt,
      tokenID,
      image,
      docId,
      time,
      readBy,
      createdAt,
      message,
      postId,
      title,
      body,
      notificationType,
      ownerId,
      status,
      fullName,
    ];
  }

  @override get stringify => true;
}