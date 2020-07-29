import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/util/model_utils.dart';

part 'comment_reply.g.dart';

@immutable
@JsonSerializable()
class CommentReply extends Equatable {
  final bool byAdmin;
  final String churchName;
  final String country;
  final String email;
  final String fullName;
  final int gender;
  final String image;
  final bool isChurch;
  final bool isVerified;
  final String ownerId;
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

  const CommentReply({
    this.byAdmin,
    this.churchName,
    this.country,
    this.createdAt,
    this.email,
    this.fullName,
    this.gender,
    this.image,
    this.isChurch,
    this.isVerified,
    this.ownerId,
    this.postId,
    this.postMessage,
    this.pushNotificationToken,
    this.time,
    this.timeUpdated,
    this.tokenID,
    this.uid,
    this.updatedAt,
    this.userImage,
    this.username,
    this.visibility,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) =>
      _$CommentReplyFromJson(json);
  Map<String, dynamic> toJson() => _$CommentReplyToJson(this);

  @override
  List get props => [
        byAdmin,
        churchName,
        country,
        createdAt,
        email,
        fullName,
        gender,
        image,
        isChurch,
        isVerified,
        ownerId,
        postId,
        postMessage,
        pushNotificationToken,
        time,
        timeUpdated,
        tokenID,
        uid,
        updatedAt,
        userImage,
        username,
        visibility,
      ];

  @override
  bool get stringify => true;
}
