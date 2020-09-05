import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';

part 'chat_entity.g.dart';

@immutable
@JsonSerializable()
class ChatEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool byAdmin;
  final String chatId;
  final String churchName;
  // final String country;
  // final String databaseName;
  // final String docId;
  // final String email;
  final String fullName;
  // final int gender;
  final String image;
  // final bool isChurch;
  final bool isRoom;
  // final bool isVerified;
  final String message;
  final String ownerId;
  final List<String> parties;
  // final String phoneNo;
  // final String pushNotificationToken;
  final List<String> readBy;
  // final List<String> searchData;
  final bool showDate;
  final int time;
  // final int timeUpdated;
  // final String tokenID;
  final int type;
  // final String uid;
  // final String userImage;
  // final String username;
  // final int visibility;
  // final List<String> hidden;
  // final bool deleted;

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

  const ChatEntity({
    this.updatedAt,
    this.createdAt,
    // this.timeUpdated,
    this.churchName,
    // this.databaseName,
    this.fullName,
    // this.isChurch,
    // this.isVerified,
    // this.phoneNo,
    // this.pushNotificationToken,
    // this.userImage,
    // this.visibility,
    this.documentId,
    this.time,
    // this.email,
    // this.country,
    this.image,
    this.ownerId,
    // this.tokenID,
    // this.username,
    this.byAdmin,
    // this.uid,
    this.message,
    // this.docId,
    this.type,
    this.parties,
    // this.gender,
    // this.searchData,
    this.chatId,
    this.isRoom,
    this.readBy,
    this.showDate,
    // this.deleted,
    // this.hidden,
  });

  String get id => this.documentId;

  factory ChatEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$ChatEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$ChatEntityToJson(this);

  @override
  List get props {
    return [
      updatedAt,
      createdAt,
      // timeUpdated,
      churchName,
      // databaseName,
      fullName,
      // isChurch,
      // isVerified,
      // phoneNo,
      // pushNotificationToken,
      // userImage,
      // visibility,
      documentId,
      // time,
      // email,
      // country,
      image,
      ownerId,
      // tokenID,
      // username,
      byAdmin,
      // uid,
      message,
      // docId,
      type,
      parties,
      // gender,
      // searchData,
      // chatId,
      // isRoom,
      readBy,
      // showDate,
      // hidden,
      // deleted
    ];
  }

  @override
  bool get stringify => true;
}
