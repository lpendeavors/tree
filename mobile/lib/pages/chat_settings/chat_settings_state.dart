import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

///
/// Message
/// 
@immutable
abstract class ChatSettingsMessage {
  const ChatSettingsMessage();
}

@immutable
abstract class ChatSettingsSavedMessage implements ChatSettingsMessage {}

class ChatSettingsSavedSuccess implements ChatSettingsSavedMessage {
  const ChatSettingsSavedSuccess();
}

class ChatSettingsSavedError implements ChatSettingsMessage {
  final Object error;
  const ChatSettingsSavedError(this.error);
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
class ChatSettingsState extends Equatable {
  final ChatSettingsItem chatSettings;
  final bool isLoading;
  final Object error;

  const ChatSettingsState({
    @required this.chatSettings,
    @required this.isLoading,
    @required this.error,
  });

  ChatSettingsState copyWith({chatSettings, isLoading, error}) {
    return ChatSettingsState(
      chatSettings: chatSettings ?? this.chatSettings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    chatSettings,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatSettingsItem extends Equatable {
  final bool messageNotifications;
  final bool chatNotifications;
  final bool groupNotifications;
  final bool onlineStatus;

  const ChatSettingsItem({
    @required this.messageNotifications,
    @required this.chatNotifications,
    @required this.groupNotifications,
    @required this.onlineStatus,
  });

  @override
  List get props => [
    messageNotifications,
    chatNotifications,
    groupNotifications,
    onlineStatus,
  ];

  @override
  bool get stringify => true;
}