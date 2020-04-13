import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import './firebase_model.dart';
import './church_info.dart';

part 'request_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class RequestEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool byAdmin;
  final ChurchInfo churchInfo;
  final String churchName;
  final String city;
  final String country;
  final String databaseName;
  final String docId;
  final String email;
  final String fullName;
  final int gender;
  final String image;
  final bool isChurch;
  final bool isVerified;
  final String ownerId;
  final String personId;
  final String phoneNo;
  final String pushNotificationToken;
  final int time;
  final int timeUpdated;
  final String tokenID;
  final String uid;
  final String userImage;
  final String username;
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

  const RequestEntity({
    this.churchInfo,
    this.visibility,
    this.userImage,
    this.username,
    this.timeUpdated,
    this.phoneNo,
    this.ownerId,
    this.fullName,
    this.databaseName,
    this.country,
    this.churchName,
    this.byAdmin,
    this.gender,
    this.createdAt,
    this.updatedAt,
    this.isChurch,
    this.image,
    this.documentId,
    this.email,
    this.tokenID,
    this.uid,
    this.time,
    this.personId,
    this.docId,
    this.pushNotificationToken,
    this.city,
    this.isVerified,
  });

  String get id => this.documentId;

  factory RequestEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$RequestEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$RequestEntityToJson(this);

  @override
  List get props {
    return [
      churchInfo,
      visibility,
      userImage,
      username,
      timeUpdated,
      phoneNo,
      ownerId,
      fullName,
      databaseName,
      country,
      churchName,
      byAdmin,
      gender,
      createdAt,
      updatedAt,
      isChurch,
      image,
      documentId,
      email,
      tokenID,
      uid,
      time,
      personId,
      docId,
      pushNotificationToken,
      city,
      isVerified,
    ];
  }

  @override
  bool get stringify => true;
}