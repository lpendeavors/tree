import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../models/old/church_info.dart';
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
  final String phoneNo;
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
  final List<ChatData> myChatsList13;
  final List<String> receivedRequests;
  final List<String> sentRequests;
  final ChurchInfo churchInfo;
  final List<String> connections;
  final List<String> shares;
  final int type;
  final String churchDenomination;
  final String churchAddress;
  final String aboutMe;
  final String title;
  final String city;
  final String relationStatus;
  final bool chatNotification;
  final bool chatOnlineStatus;
  final bool groupNotification;
  final bool messageNotification;
  final bool isAdmin;
  final String businessAddress;
  final int status;
  final String churchWebsite;
  final String parentChurch;
  final double churchLat;
  final double churchLong;

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
    this.phoneNo,
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
    this.myChatsList13,
    this.receivedRequests,
    this.sentRequests,
    this.churchInfo,
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
    this.chatNotification,
    this.chatOnlineStatus,
    this.groupNotification,
    this.messageNotification,
    this.isAdmin,
    this.businessAddress,
    this.status,
    this.churchWebsite,
    this.parentChurch,
    this.churchLat,
    this.churchLong
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
      phoneNo,
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
      myChatsList13,
      receivedRequests,
      sentRequests,
      churchInfo,
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
      chatOnlineStatus,
      groupNotification,
      messageNotification,
      isAdmin,
      businessAddress,
      status,
      churchWebsite,
      parentChurch,
      churchLat,
      churchLong
    ];
  }

  static Map<String, dynamic> createWith(Map<String, dynamic> data){
    //TODO: isChurch, searchData
    return {
      'databaseName': "userBase",
      'docId': data['uid'],
      'isPublic': false,
      'phoneVerified': true,
      'signUpComplete': false,
      'treeTrophies': [
        {
          'trophyCount': [data['uid']],
          'trophyIcon': 'assets/trophy/t0.png',
          'trophyInfo': 'Verify phone number',
          'trophyKey': 'verifyNumber',
          'trophyUnlockAt': 1,
          'trophyUnlocked': false,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t1.png',
          'trophyInfo': 'Watch your first 25 videos',
          'trophyKey': 'watchVideos',
          'trophyUnlockAt': 25,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t2.png',
          'trophyInfo': 'Watch your first 75 videos',
          'trophyKey': 'watchVideos',
          'trophyUnlockAt': 75,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t3.png',
          'trophyInfo': 'Create your first event',
          'trophyKey': 'createEvent',
          'trophyUnlockAt': 1,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t4.png',
          'trophyInfo': 'Create 5 events',
          'trophyKey': 'createEvent',
          'trophyUnlockAt': 5,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t5.png',
          'trophyInfo': 'Post your first 15 word statuses',
          'trophyKey': 'postWord',
          'trophyUnlockAt': 15,
          'trophyWon': false,
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t6.png',
          'trophyInfo': 'Post your first 50 word statuses',
          'trophyKey': 'postWord',
          'trophyUnlockAt': 50,
          'trophyWon': false,
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t7.png',
          'trophyInfo': 'Like 50 posts',
          'trophyKey': 'likePost',
          'trophyUnlockAt': 50,
          'trophyWon': false,
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t8.png',
          'trophyInfo': 'Like 150 posts',
          'trophyKey': 'likePost',
          'trophyUnlockAt': 150,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t9.png',
          'trophyInfo': 'Comment on 25 posts',
          'trophyKey': 'commentPost',
          'trophyUnlockAt': 25,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t10.png',
          'trophyInfo': 'Comment on 75 posts',
          'trophyKey': 'commentPost',
          'trophyUnlockAt': 75,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t11.png',
          'trophyInfo': 'Share 25 people\'s posts',
          'trophyKey': 'sharePost',
          'trophyUnlockAt': 25,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t12.png',
          'trophyInfo': 'Share 75 people\'s post',
          'trophyKey': 'sharePost',
          'trophyUnlockAt': 75,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t13.png',
          'trophyInfo': 'Share 150 people\'s post',
          'trophyKey': 'sharePost',
          'trophyUnlockAt': 150,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t14.png',
          'trophyInfo': 'Connect with 50 people',
          'trophyKey': 'connectWith',
          'trophyUnlockAt': 50,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t15.png',
          'trophyInfo': 'Connect with 100 people',
          'trophyKey': 'connectWith',
          'trophyUnlockAt': 100,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t16.png',
          'trophyInfo': 'Post your first 10 media posts',
          'trophyKey': 'mediaPost',
          'trophyUnlockAt': 10,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t17.png',
          'trophyInfo': 'Post your first 25 media posts',
          'trophyKey': 'mediaPost',
          'trophyUnlockAt': 25,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t18.png',
          'trophyInfo': 'Comment 100 times in the chat rooms',
          'trophyKey': 'commentChat',
          'trophyUnlockAt': 100,
          'trophyWon': false
        },
        {
          'trophyCount': [],
          'trophyIcon': 'assets/trophy/t19.png',
          'trophyInfo': 'Comment 250 times in the chat rooms',
          'trophyKey': 'commentChat',
          'trophyUnlockAt': 250,
          'trophyWon': false
        },
      ],
      'trophyCreated': true,
      'visibility': 0,
      'newApp1': true,
      ...data
    };
  }

  @override
  bool get stringify => true;
}