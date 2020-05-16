import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import 'group_member.dart';

part 'group_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class GroupEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool byAdmin;
  // final String churchName;
  // final String country;
  // final String creatorsMessage;
  // final String databaseName;
  // final String docId;
  // final String email;
  final String fullName;
  // final int gender;
  final String groupId;
  final String groupImage;
  final List<GroupMember> groupMembers;
  final String image;
  // final bool isChurch;
  final bool isConversation;
  final bool isGroup;
  final bool isGroupPrivate;
  final bool isRoom;
  // final bool isVerified;
  final String ownerId;
  // final String phoneNo;
  // final String pushNotificationToken;
  // final List<String> searchData;
  // final int time;
  // final int timeUpdated;
  // final String tokenID;
  final String uid;
  // final String userImage;
  // final String username;
  // final int visibility;

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

  const GroupEntity({
    this.createdAt,
    this.updatedAt,
    this.ownerId,
    this.byAdmin,
    this.documentId,
    // this.timeUpdated,
    // this.churchName,
    // this.databaseName,
    this.fullName,
    // this.isChurch,
    // this.isVerified,
    // this.phoneNo,
    // this.pushNotificationToken,
    // this.userImage,
    // this.visibility,
    // this.tokenID,
    // this.searchData,
    // this.time,
    // this.email,
    this.image,
    // this.username,
    this.uid,
    // this.gender,
    // this.docId,
    this.isRoom,
    // this.country,
    this.isGroup,
    // this.creatorsMessage,
    this.groupId,
    this.groupImage,
    this.groupMembers,
    this.isConversation,
    this.isGroupPrivate,
  });

  String get id => this.documentId;

  factory GroupEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$GroupEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$GroupEntityToJson(this);

  @override
  List get props {
    return [
      createdAt,
      updatedAt,
      ownerId,
      byAdmin,
      documentId,
      // timeUpdated,
      // churchName,
      // databaseName,
      fullName,
      // isChurch,
      // isVerified,
      // phoneNo,
      // pushNotificationToken,
      // userImage,
      // visibility,
      // tokenID,
      // searchData,
      // time,
      // email,
      image,
      // username,
      uid,
      // gender,
      // docId,
      isRoom,
      // country,
      // isGroup,
      // creatorsMessage,
      groupId,
      groupImage,
      groupMembers,
      isConversation,
      isGroupPrivate,
    ];
  }

  @override
  bool get stringify => true;
}