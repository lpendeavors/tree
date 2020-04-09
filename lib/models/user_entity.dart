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
  final String firstName;
  final String lastName;
  final String fullName;
  final bool isChurch;
  final int isOnline1;
  final bool isPublic;
  final bool newApp1;
  final String password;
  final String phoneNumber;
  final bool phoneVerified;
  final String pushNotificationToken;
  final List<Map<int,String>> searchData;
  final bool signUpComplete;
  final Timestamp time;
  final Timestamp timeOnline;
  final Timestamp timeUpdated;
  final String tokenID;
  final List<Map<int,dynamic>> treeTrophies;
  final bool trophyCreated;
  final String uid;
  final int visibility;

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

  const UserEntity({
    this.documentId,
    this.email,
    this.fullName,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.isChurch,
    this.isOnline1,
    this.isPublic,
    this.lastName,
    this.newApp1,
    this.password,
    this.phoneNumber,
    this.phoneVerified,
    this.pushNotificationToken,
    this.searchData,
    this.signUpComplete,
    this.time,
    this.timeOnline,
    this.timeUpdated,
    this.tokenID,
    this.treeTrophies,
    this.trophyCreated,
    this.uid,
    this.visibility,
  });

  String get id => this.documentId;

  factory UserEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
    _$UserEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      email,
      fullName,
      createdAt,
      updatedAt,
      firstName,
      isChurch,
      isOnline1,
      isPublic,
      lastName,
      newApp1,
      password,
      phoneNumber,
      phoneVerified,
      pushNotificationToken,
      searchData,
      signUpComplete,
      time,
      timeOnline,
      timeUpdated,
      tokenID,
      treeTrophies,
      trophyCreated,
      uid,
      visibility,
    ];
  }

  @override
  bool get stringify => true;
}