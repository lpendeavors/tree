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
  final int type;

  const ProfileSettingsState({
    @required this.isLoading,
    @required this.error,
    @required this.isChurch,
    @required this.firstName,
    @required this.lastName,
    @required this.phoneNo,
    @required this.type,
  });

  ProfileSettingsState copyWith({isLoading, error, isChurch, firstName, lastName, phoneNo, type}) {
    return ProfileSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isChurch: isChurch ?? this.isChurch,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNo: phoneNo ?? this.phoneNo,
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
    type
  ];

  @override
  bool get stringify => true;
}