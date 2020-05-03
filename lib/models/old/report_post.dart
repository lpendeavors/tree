import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';

part 'report_post.g.dart';

@immutable
@JsonSerializable()
class ReportPost extends Equatable {
  final bool byAdmin;
  final String churchName;
  final String country;
  final String databaseName;
  final String docId;
  final String email;
  final List<String> fileToUpload;
  final bool fileUploaded;
  final String fullName;
  final int gender;
  final String image;
  final bool isAdmin;
  final bool isChurch;
  final bool isHidden;
  final int isHostPrivate;
  final bool isReported;
  final String ownerId;
  final List<String> parties;
  final String phoneNo;
  final String postMessage;
  final List<String> tags;
  final int time;
  final int timeUpdated;
  final String tokenID;
  final int type;
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

  const ReportPost({
    this.tokenID,
    this.isChurch,
    this.updatedAt,
    this.createdAt,
    this.byAdmin,
    this.churchName,
    this.country,
    this.databaseName,
    this.fullName,
    this.ownerId,
    this.phoneNo,
    this.timeUpdated,
    this.username,
    this.userImage,
    this.visibility,
    this.docId,
    this.time,
    this.uid,
    this.email,
    this.image,
    this.gender,
    this.postMessage,
    this.parties,
    this.isReported,
    this.isHostPrivate,
    this.fileUploaded,
    this.fileToUpload,
    this.type,
    this.isAdmin,
    this.isHidden,
    this.tags,
  });

  factory ReportPost.fromJson(Map<String, dynamic> json) => _$ReportPostFromJson(json);
  Map<String, dynamic> toJson() => _$ReportPostToJson(this);

  @override
  List get props {
    return [
      byAdmin,
      churchName,
      country,
      databaseName,
      docId,
      email,
      fileToUpload,
      fileUploaded,
      fullName,
      gender,
      image,
      isAdmin,
      isChurch,
      isHidden,
      isHostPrivate,
      isReported,
      ownerId,
      parties,
      phoneNo,
      postMessage,
      tags,
      time,
      timeUpdated,
      tokenID,
      type,
      uid,
      username,
      userImage,
      visibility,
    ];
  }

  @override
  bool get stringify => true;
}