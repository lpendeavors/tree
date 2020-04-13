import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import './firebase_model.dart';

part 'reference_entity.g.dart';

@immutable
@JsonSerializable()
class ReferenceEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String databaseName;
  final String fileUrl;
  final String reference;
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

  const ReferenceEntity({
    this.createdAt,
    this.updatedAt,
    this.documentId,
    this.timeUpdated,
    this.databaseName,
    this.visibility,
    this.time,
    this.fileUrl,
    this.reference,
  });

  String get id => this.documentId;

  factory ReferenceEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$ReferenceEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$ReferenceEntityToJson(this);

  @override
  List get props {
    return [
      createdAt,
      updatedAt,
      documentId,
      timeUpdated,
      databaseName,
      visibility,
      time,
      fileUrl,
      reference,
    ];
  }

  @override
  bool get stringify => true;
}