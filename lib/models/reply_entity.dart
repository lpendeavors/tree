import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import './firebase_model.dart';

part 'reply_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class ReplyEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String databaseName;
  final String postId;
  final String postMessage;
  final int time;
  final int timeUpdated;
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

  const ReplyEntity({
    this.databaseName,
    this.visibility,
    this.timeUpdated,
    this.documentId,
    this.updatedAt,
    this.createdAt,
    this.time,
    this.postId,
    this.postMessage,
  });

  String get id => this.documentId;

  factory ReplyEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$ReplyEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$ReplyEntityToJson(this);

  @override
  List get props {
    return [
      databaseName,
      visibility,
      timeUpdated,
      documentId,
      updatedAt,
      createdAt,
      time,
      postId,
      postMessage,
    ];
  }

  @override
  bool get stringify => true;
}