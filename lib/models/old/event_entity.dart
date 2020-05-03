import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import 'event_data.dart';

part 'event_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class EventEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final bool isAdmin;
  final String churchName;
  final String databaseName;
  final String docId;
  final String email;
  final List<EventData> eventData;
  final String eventDetails;
  final int eventEndDate;
  final int eventEndTime;
  final int eventIndex;
  final double eventLatitude;
  final double eventLongitude;
  final double eventPrice;
  final int eventStartDate;
  final int eventStartTime;
  final String eventTitle;
  final String eventWebAddress;
  final String fullName;
  final int gender;
  final String image;
  final bool isChurch;
  final bool isHidden;
  final bool isReported;
  final bool isSponsored;
  final bool isVerified;
  final String location;
  final String ownerId;
  final String phoneNo;
  final String pushNotificationToken;
  final String reason;
  final List<String> searchData;
  final double sponsorFee;
  final int time;
  final int status;
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
  final Timestamp createAt;
  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp updateAt;

  const EventEntity({
    this.docId,
    this.type,
    this.searchData,
    this.gender,
    this.tokenID,
    this.visibility,
    this.userImage,
    this.pushNotificationToken,
    this.phoneNo,
    this.isVerified,
    this.isChurch,
    this.fullName,
    this.databaseName,
    this.churchName,
    this.timeUpdated,
    this.documentId,
    this.uid,
    this.isAdmin,
    this.username,
    this.ownerId,
    this.image,
    this.email,
    this.time,
    this.updateAt,
    this.isReported,
    this.isHidden,
    this.createAt,
    this.eventData,
    this.eventDetails,
    this.eventEndDate,
    this.eventEndTime,
    this.eventIndex,
    this.eventLatitude,
    this.eventLongitude,
    this.eventPrice,
    this.eventStartDate,
    this.eventStartTime,
    this.eventTitle,
    this.eventWebAddress,
    this.isSponsored,
    this.location,
    this.reason,
    this.sponsorFee,
    this.status,
  });

  String get id => this.documentId;

  factory EventEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$EventEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$EventEntityToJson(this);

  @override
  List get props {
    return [
      docId,
      type,
      searchData,
      gender,
      tokenID,
      visibility,
      userImage,
      pushNotificationToken,
      phoneNo,
      isVerified,
      isChurch,
      fullName,
      databaseName,
      churchName,
      timeUpdated,
      documentId,
      uid,
      isAdmin,
      username,
      ownerId,
      image,
      email,
      time,
      updateAt,
      isReported,
      isHidden,
      createAt,
      eventData,
      eventDetails,
      eventEndTime,
      eventEndDate,
      eventIndex,
      eventLatitude,
      eventLongitude,
      eventPrice,
      eventStartTime,
      eventStartDate,
      eventTitle,
      eventWebAddress,
      isSponsored,
      location,
      reason,
      sponsorFee,
      status,
    ];
  }

  @override
  bool get stringify => true;
}