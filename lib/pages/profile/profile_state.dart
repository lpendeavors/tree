import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../models/old/church_info.dart';
import '../../pages/feed/feed_state.dart';
import '../../models/old/trophy.dart';

///
/// Message
/// 
abstract class ProfileMessage {
  const ProfileMessage();
}

///
/// Error 
/// 
class ProfileNotLoggedInError {
  const ProfileNotLoggedInError();
}

/// 
/// State
/// 
@immutable
class ProfileState extends Equatable {
  final ProfileItem profile;
  final bool isLoading;
  final Object error;

  const ProfileState({
    @required this.profile,
    @required this.isLoading,
    @required this.error,
  });

  ProfileState copyWith({profile, isLoading, error}) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    profile,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}

@immutable
class RecentFeedState extends Equatable {
  final List<FeedItem> feedItems;
  final bool isLoading;
  final Object error;

  const RecentFeedState({
    @required this.feedItems,
    @required this.isLoading,
    @required this.error,
  });

  RecentFeedState copyWith({feedItems, isLoading, error}) {
    return RecentFeedState(
      feedItems: feedItems ?? this.feedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    feedItems,
    isLoading,
    error
  ];

  @override
  bool get stringify => true;
}

@immutable
class ProfileItem extends Equatable {
  final String id;
  final String uid;
  final String photo;
  final bool isVerified;
  final bool isChurch;
  final String fullName;
  final String churchName;
  final List<String> connections;
  final List<String> shares;
  final List<Trophy> trophies;
  final int type;
  final String churchDenomination;
  final String churchAddress;
  final String aboutMe;
  final String title;
  final String city;
  final String relationStatus;
  final ChurchInfo churchInfo;
  final bool myProfile;

  final bool isFriend;
  final bool sent;
  final bool received;

  const ProfileItem({
    @required this.id,
    @required this.uid,
    @required this.photo,
    @required this.isVerified,
    @required this.isChurch,
    @required this.fullName,
    @required this.churchName,
    @required this.connections,
    @required this.trophies,
    @required this.type,
    @required this.churchDenomination,
    @required this.churchAddress,
    @required this.aboutMe,
    @required this.title,
    @required this.city,
    @required this.relationStatus,
    @required this.churchInfo,
    @required this.shares,
    @required this.myProfile,
    @required this.isFriend,
    @required this.sent,
    @required this.received,
  });

  @override
  List get props => [
    id,
    uid,
    photo,
    isVerified,
    isChurch,
    fullName,
    churchName,
    connections,
    shares,
    trophies,
    type,
    churchDenomination,
    churchAddress,
    aboutMe,
    title,
    city,
    relationStatus,
    churchInfo,
    myProfile,
    isFriend,
    sent,
    received
  ];

  @override
  bool get stringify => true;
}