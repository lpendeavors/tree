import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class ProfileSettingsMessage {
  const ProfileSettingsMessage();
}

class SettingsMessageSuccess implements ProfileSettingsMessage {
  const SettingsMessageSuccess();
}

///
/// Error
///
class SettingsNotLoggedInError {
  const SettingsNotLoggedInError();
}

///
/// State
///
@immutable
class ProfileSettingsState extends Equatable {
  final bool isLoading;
  final Object error;
  final bool isChurch;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String relationship;
  final bool isPublic;
  final String title;
  final String bio;
  final int type;

  const ProfileSettingsState({
    @required this.isLoading,
    @required this.error,
    @required this.isChurch,
    @required this.firstName,
    @required this.lastName,
    @required this.phoneNo,
    @required this.relationship,
    @required this.isPublic,
    @required this.title,
    @required this.bio,
    @required this.type,
  });

  ProfileSettingsState copyWith({isLoading, error, isChurch, firstName, lastName, phoneNo, relationship, isPublic, title, bio, type}) {
    return ProfileSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isChurch: isChurch ?? this.isChurch,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNo: phoneNo ?? this.phoneNo,
      relationship: relationship ?? this.relationship,
      isPublic: isPublic ?? this.isPublic,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      type: type ?? this.type,
    );
  }

  @override
  List get props => [
    isLoading,
    error,
    isChurch,
    firstName,
    lastName,
    phoneNo,
    relationship,
    isPublic,
    title,
    bio,
    type
  ];

  @override
  bool get stringify => true;
}