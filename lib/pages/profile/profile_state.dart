import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/church_info.dart';
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
class NotLoggedInError {
  const NotLoggedInError();
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
class ProfileItem extends Equatable {
  final String id;
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

  const ProfileItem({
    @required this.id,
    @required this.photo,
    @required this.isVerified,
    @required this.isChurch,
    @required this.fullName,
    @required this.churchName,
    @required this.connections,
    @required this.shares,
    @required this.trophies,
    @required this.type,
    @required this.churchDenomination,
    @required this.churchAddress,
    @required this.aboutMe,
    @required this.title,
    @required this.city,
    @required this.relationStatus,
    @required this.churchInfo
  });

  @override
  List get props => [
    id,
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
    churchInfo
  ];

  @override
  bool get stringify => true;
}