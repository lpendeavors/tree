import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/church_info.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './user_chat_data.dart';
import './trophy.dart';

part 'user_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class UserEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String churchName;
  final bool isChurch;
  final bool isVerified;
  final int isOnline1;
  final bool isPublic;
  final bool newApp1;
  final String password;
  final String phoneNumber;
  final bool phoneVerified;
  final String pushNotificationToken;
  final List<String> searchData;
  final bool signUpComplete;
  final String tokenID;
  final List<Trophy> treeTrophies;
  final bool trophyCreated;
  final String uid;
  final String image;
  final int visibility;
  final int time;
  final int timeOnline;
  final int timeUpdated;
  final List<ChatData> myChatList13;
  final List<String> connections;
  final List<String> shares;
  final int type;
  final String churchDenomination;
  final String churchAddress;
  final String aboutMe;
  final String title;
  final String city;
  final String relationStatus;
  final ChurchInfo churchInfo;

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
  @JsonKey(
      fromJson: timestampFromJson,
      toJson: timestampToJson
  )

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
    this.image,
    this.visibility,
    this.myChatList13,
    this.churchName,
    this.isVerified,
    this.connections,
    this.shares,
    this.type,
    this.churchDenomination,
    this.churchAddress,
    this.aboutMe,
    this.title,
    this.city,
    this.relationStatus,
    this.churchInfo
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
      myChatList13,
      image,
      isVerified,
      churchName,
      connections,
      shares,
      type,
      churchDenomination,
      churchAddress,
      aboutMe,
      title,
      city,
      relationStatus,
      churchInfo
    ];
  }

  @override
  bool get stringify => true;
}