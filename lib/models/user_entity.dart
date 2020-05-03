import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import 'firebase_model.dart';

part 'user_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class UserEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool church;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String photo;
  final String location;
  final bool private;
  final List<String> trophies;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp joined;

  const UserEntity({
    this.documentId,
    this.church,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.photo,
    this.location,
    this.private,
    this.trophies,
    this.joined
  });

  String get id => this.documentId;

  factory UserEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$UserEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      church,
      email,
      firstName,
      lastName,
      phone,
      photo,
      location,
      private,
      trophies
    ];
  }

  @override
  bool get stringify => true;
}