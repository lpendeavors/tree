import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// 
/// Enums
/// 
enum SettingsType { 
  updatePersonal, 
  updateChurch, 
  updatePhone 
}

enum PolicyType { 
  privacyPolicy,
  termsOfService,
}

enum LogoutType { 
  deactivate, 
  logOut 
}

///
/// Message
///
@immutable
abstract class SettingsMessage {}

/// 
/// Error
/// 
@immutable 
abstract class SettingsError {}

class NotLoggedInError {
  const NotLoggedInError();
}

/// 
/// State
/// 
@immutable
class SettingsState extends Equatable {
  final UserInfo userInfo;
  final NotificationSettings notificationSettings;
  final bool isLoading;
  final Object error;

  const SettingsState({
    this.userInfo,
    this.notificationSettings,
    this.isLoading,
    this.error,
  });

  SettingsState copyWith({userInfo, isLoading, error}) {
    return SettingsState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    userInfo, 
    isLoading, 
    error
  ];

  @override
  bool get stringify => true;
}

@immutable
class UserInfo extends Equatable {
  final String id;

  const UserInfo({
    @required this.id,
  });

  @override 
  List get props => [
    id
  ];

  @override
  bool get stringify => true;
}

@immutable
class NotificationSettings extends Equatable {
  final String id;

  const NotificationSettings({
    @required this.id,
  });

  @override
  List get props => [
    id
  ];

  @override
  bool get stringify => true;
}