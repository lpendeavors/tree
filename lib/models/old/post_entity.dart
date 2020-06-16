import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './post_data.dart';

part 'post_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class PostEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool byAdmin;
  final String churchName;
  final String country;
  final String databaseName;
  final String docId;
  final String email;
  final bool fileUploaded;
  final String fullName;
  final int gender;
  final String image;
  final bool isAdmin;
  final bool isChurch;
  final bool isGroup;
  final bool isHidden;
  final int isPostPrivate;
  final bool isReported;
  final bool isVerified;
  final String ownerId;
  final List<String> parties;
  final String phoneNo;
  final String postMessage;
  final String pushNotificationToken;
  final List<String> tags;
  final String tokenID;
  final List<PostData> postData;
  final int type;
  final String uid;
  final String userImage;
  final String username;
  final int visibility;
  final int time;
  final List<String> likes;

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

  const PostEntity({
    this.documentId,
    this.createdAt,
    this.updatedAt,
    this.visibility,
    this.tokenID,
    this.pushNotificationToken,
    this.isChurch,
    this.uid,
    this.byAdmin,
    this.churchName,
    this.country,
    this.databaseName,
    this.docId,
    this.email,
    this.fileUploaded,
    this.fullName,
    this.gender,
    this.image,
    this.isAdmin,
    this.isGroup,
    this.isHidden,
    this.isPostPrivate,
    this.isReported,
    this.isVerified,
    this.ownerId,
    this.parties,
    this.phoneNo,
    this.postData,
    this.postMessage,
    this.tags,
    this.type,
    this.userImage,
    this.username,
    this.time,
    this.likes,
  });

  String get id => this.documentId;

  factory PostEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$PostEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$PostEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      byAdmin,
      churchName,
      country,
      createdAt,
      databaseName,
      docId,
      email,
      fileUploaded,
      fullName,
      gender,
      image,
      isAdmin,
      isChurch,
      isGroup,
      isHidden,
      isPostPrivate,
      isReported,
      isVerified,
      ownerId,
      parties,
      phoneNo,
      postData,
      postMessage,
      pushNotificationToken,
      tags,
      tokenID,
      type,
      uid,
      updatedAt,
      userImage,
      username,
      visibility,
      time,
      likes,
    ];
  }

  @override
  bool get stringify => true;
}