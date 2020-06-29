import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/church_info.dart';
import 'package:treeapp/models/old/user_entity.dart';

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
  final UserEntity userEntity;

  const ProfileSettingsState({
    @required this.isLoading,
    @required this.error,
    @required this.userEntity
  });

  ProfileSettingsState copyWith({isLoading, error, userEntity}) {
    return ProfileSettingsState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        userEntity: userEntity ?? this.userEntity
    );
  }

  @override
  List get props => [
    isLoading,
    error,
    userEntity
  ];

  @override
  bool get stringify => true;
}