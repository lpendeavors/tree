import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import './firebase_model.dart';

part 'user_entity.g.dart';

@immutable
@JsonSerializable()
class UserEntity extends Equatable implements FirebaseModel {
  @JsonKey(name: 'documentId')
  final String documentId;

  final String email;

  @JsonKey(name: 'full_name')
  final String fullName;

  @JsonKey(
    name: 'created_at',
    fromJson: timestampFromJson,
    toJson: timestampToJson
  )
  final Timestamp createdAt;

  @JsonKey(
    name: 'updated_at',
    fromJson: timestampFromJson,
    toJson: timestampToJson
  )
  final Timestamp updatedAt;

  const UserEntity({
    this.documentId,
    this.email,
    this.fullName,
    this.createdAt,
    this.updatedAt,
  });

  String get id => this.documentId;

  factory UserEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
    _$UserEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  List get props {
    return [documentId, email, fullName, createdAt, updatedAt];
  }

  @override
  bool get stringify => true;
}