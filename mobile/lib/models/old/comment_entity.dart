import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './comment_reply.dart';

part 'comment_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class CommentEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool isAdmin;
  final String churchName;
  final String country;
  final String databaseName;
  final String email;
  final String fullName;
  final int gender;
  final String image;
  final bool isChurch;
  final bool isVerified;
  final List<String> likes;
  final String ownerId;
  final String phoneNo;
  final String postId;
  final String postMessage;
  final String pushNotificationToken;
  final int time;
  final int timeUpdated;
  final String tokenID;
  final String uid;
  final String userImage;
  final String username;
  final int visibility;
  final bool isGIF;
  final String imagePath;
  final List<CommentReply> replies;

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

  const CommentEntity({
    this.documentId,
    this.uid,
    this.isAdmin,
    this.username,
    this.visibility,
    this.userImage,
    this.tokenID,
    this.pushNotificationToken,
    this.postMessage,
    this.phoneNo,
    this.ownerId,
    this.isVerified,
    this.isChurch,
    this.image,
    this.gender,
    this.fullName,
    this.databaseName,
    this.country,
    this.churchName,
    this.email,
    this.timeUpdated,
    this.time,
    this.createdAt,
    this.likes,
    this.postId,
    this.updatedAt,
    this.isGIF,
    this.imagePath,
    this.replies,
  });

  String get id => this.documentId;

  factory CommentEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$CommentEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$CommentEntityToJson(this);

  factory CommentEntity.fromJson(Map<String, dynamic> json) =>
      _$CommentEntityFromJson(json);

  @override
  List get props {
    return [
      documentId,
      uid,
      isAdmin,
      username,
      visibility,
      userImage,
      tokenID,
      pushNotificationToken,
      postMessage,
      phoneNo,
      ownerId,
      isVerified,
      isChurch,
      image,
      gender,
      fullName,
      databaseName,
      country,
      churchName,
      email,
      timeUpdated,
      time,
      createdAt,
      likes,
      postId,
      updatedAt,
      isGIF,
      imagePath,
      replies,
    ];
  }
}
