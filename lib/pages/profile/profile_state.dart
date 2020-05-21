import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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

  const ProfileItem({
    @required this.id,
    @required this.photo,
    @required this.isVerified,
    @required this.isChurch,
    @required this.fullName,
    @required this.churchName,
  });

  @override
  List get props => [
    id,
    photo,
    isVerified,
    isChurch,
    fullName,
    churchName
  ];

  @override
  bool get stringify => true;
}