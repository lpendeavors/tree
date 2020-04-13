import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import './firebase_model.dart';
import './report_post.dart';

part 'report_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class ReportEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool byAdmin;
  final String churchName;
  final String country;
  final String databaseName;
  final String email;
  final String fullName;
  final int gender;
  final String image;
  final bool isChurch;
  final String ownerId;
  final String phoneNo;
  final ReportPost reportPost;
  final String reportReason;
  final int reportType;
  final int status;
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

  const ReportEntity({
    this.documentId,
    this.reportPost,
    this.image,
    this.fullName,
    this.isChurch,
    this.time,
    this.uid,
    this.userImage,
    this.churchName,
    this.tokenID,
    this.status,
    this.email,
    this.phoneNo,
    this.databaseName,
    this.visibility,
    this.updatedAt,
    this.createdAt,
    this.timeUpdated,
    this.ownerId,
    this.country,
    this.gender,
    this.username,
    this.byAdmin,
    this.reportReason,
    this.reportType,
  });

  String get id => this.documentId;

  factory ReportEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$ReportEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$ReportEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      reportPost,
      image,
      fullName,
      isChurch,
      time,
      uid,
      userImage,
      churchName,
      tokenID,
      status,
      email,
      phoneNo,
      databaseName,
      visibility,
      updatedAt,
      createdAt,
      timeUpdated,
      ownerId,
      country,
      gender,
      username,
      byAdmin,
      reportReason,
      reportType,
    ];
  }

  @override
  bool get stringify => true;
}