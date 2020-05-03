import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import './reply_chat.dart';
import './reply_search.dart';
import './church_info.dart';
import './trophy.dart';

part 'reply_owner.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class ReplyOwner extends Equatable {
  final String aboutMe;
  final List<String> attending;
  final String businessAddress;
  final String churchId;
  final ChurchInfo churchInfo;
  final bool churchNotFound;
  final bool chuchVerified;
  final String city;
  final List<String> connections;
  final String databaseName;
  final String docId;
  final String email;
  final String firstName;
  final String fullName;
  final bool hasChurch;
  final String image;
  final bool isAdmin;
  final bool isChurch;
  final bool isChurchUpdated;
  final int isOnline1;
  final bool isPersonalUpdated;
  final bool isPublic;
  final bool isTyping;
  final bool isVerified;
  final String lastName;
  final List<ReplyChat> myChatsList13;
  final bool myConnect;
  final bool newApp1;
  final String password;
  final String phoneNo;
  final bool phoneVerified;
  final String pushNotificationToken;
  final List<String> receivedRequests;
  final List<ReplySearch> recentSearch;
  final String relationStatus;
  final List<String> searchData;
  final bool signUpComplete;
  final int status;
  final int time;
  final int timeOnline;
  final String title;
  final String tokenID;
  final List<Trophy> treeTrophies;
  final bool trophyCreated;
  final bool typing;
  final String uid;
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

  const ReplyOwner({
    this.churchInfo,
    this.createdAt,
    this.updatedAt,
    this.visibility,
    this.databaseName,
    this.time,
    this.tokenID,
    this.title,
    this.docId,
    this.image,
    this.searchData,
    this.pushNotificationToken,
    this.phoneNo,
    this.isVerified,
    this.isChurch,
    this.fullName,
    this.uid,
    this.email,
    this.isAdmin,
    this.status,
    this.trophyCreated,
    this.treeTrophies,
    this.timeOnline,
    this.signUpComplete,
    this.phoneVerified,
    this.newApp1,
    this.lastName,
    this.isPublic,
    this.isOnline1,
    this.firstName,
    this.password,
    this.aboutMe,
    this.attending,
    this.businessAddress,
    this.chuchVerified,
    this.churchId,
    this.churchNotFound,
    this.city,
    this.connections,
    this.hasChurch,
    this.isChurchUpdated,
    this.isPersonalUpdated,
    this.isTyping,
    this.myChatsList13,
    this.myConnect,
    this.receivedRequests,
    this.recentSearch,
    this.relationStatus,
    this.typing,
  });

  factory ReplyOwner.fromJson(Map<String, dynamic> json) => _$ReplyOwnerFromJson(json);
  Map<String, dynamic> toJson() => _$ReplyOwnerToJson(this);

  @override
  List get props {
    return [
      churchInfo,
      createdAt,
      updatedAt,
      visibility,
      databaseName,
      time,
      tokenID,
      title,
      docId,
      image,
      searchData,
      pushNotificationToken,
      phoneNo,
      isVerified,
      isChurch,
      fullName,
      uid,
      email,
      isAdmin,
      status,
      trophyCreated,
      treeTrophies,
      timeOnline,
      signUpComplete,
      phoneVerified,
      newApp1,
      lastName,
      isPublic,
      isOnline1,
      firstName,
      password,
      aboutMe,
      attending,
      businessAddress,
      chuchVerified,
      churchId,
      churchNotFound,
      city,
      connections,
      hasChurch,
      isChurchUpdated,
      isPersonalUpdated,
      isTyping,
      myChatsList13,
      myConnect,
      receivedRequests,
      recentSearch,
      relationStatus,
      typing,
    ];
  }

  @override
  bool get stringify => true;
}