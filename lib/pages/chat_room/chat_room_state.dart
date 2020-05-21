import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// 
/// Message
///
abstract class ChatRoomMessage {
  const ChatRoomMessage();
}

abstract class ChatMessageAdded implements ChatRoomMessage {
  const ChatMessageAdded();
}

class ChatMessageAddedSuccess implements ChatMessageAdded {
  const ChatMessageAddedSuccess();
}

class ChatMessageAddedError implements ChatMessageAdded {
  const ChatMessageAddedError();
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
class ChatRoomState extends Equatable {
  final ChatRoomItem details;
  final List<ChatMessageItem> messages;
  final bool isLoading;
  final Object error;

  const ChatRoomState({
    @required this.details,
    @required this.messages,
    @required this.isLoading,
    @required this.error,
  });

  ChatRoomState copyWith({details, messages, isLoading, error}) {
    return ChatRoomState(
      details: details ?? this.details,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    details,
    messages,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatRoomItem extends Equatable {
  final String id;

  const ChatRoomItem({
    @required this.id,
  });

  @override
  List get props => [
    id,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatMessageItem extends Equatable {
  final String id;

  const ChatMessageItem({
    @required this.id,
  });

  @override
  List get props => [
    id,
  ];

  @override
  bool get stringify => true;
}