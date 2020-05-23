import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../models/old/church_info.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './user_chat_data.dart';
import './trophy.dart';

part 'user_preview_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class UserPreviewEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String uid;
  final String image;
  final bool isChurch;
  final String fullName;
  final String churchName;
  final String aboutMe;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson
  )
  final Timestamp createdAt;
  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson
  )
  final Timestamp updatedAt;
  @JsonKey(
      fromJson: timestampFromJson,
      toJson: timestampToJson
  )

  const UserPreviewEntity({
    this.documentId,
    this.uid,
    this.image,
    this.isChurch,
    this.fullName,
    this.churchName,
    this.aboutMe,
    this.createdAt,
    this.updatedAt
  });

  String get id => this.documentId;

  factory UserPreviewEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
    _$UserPreviewEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$UserPreviewEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      uid,
      image,
      isChurch,
      fullName,
      churchName,
      aboutMe,
      createdAt,
      updatedAt
    ];
  }

  @override
  bool get stringify => true;
}