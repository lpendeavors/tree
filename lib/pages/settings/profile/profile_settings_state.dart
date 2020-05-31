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
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const ProfileSettingsState({
    @required this.isLoading,
    @required this.error,
    @required this.firstName,
    @required this.lastName,
    @required this.phoneNumber,
  });

  ProfileSettingsState copyWith({isLoading, error, firstName, lastName, phoneNumber}) {
    return ProfileSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List get props => [
    isLoading,
    error,
    firstName,
    lastName,
    phoneNumber
  ];

  @override
  bool get stringify => true;
}