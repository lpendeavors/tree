import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/group_member.dart';

/// 
/// Enums
///
enum MessageType { text, image, gif, doc, video }

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
  final bool isGroup;
  final bool isConversation;
  final List<GroupMember> members;
  final String image;
  final String groupImage;
  final String name;

  const ChatRoomItem({
    @required this.id,
    @required this.isGroup,
    @required this.isConversation,
    @required this.members,
    @required this.image,
    @required this.groupImage,
    @required this.name,
  });

  @override
  List get props => [
    id,
    isGroup,
    isConversation,
    members,
    image,
    groupImage,
    name,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatMessageItem extends Equatable {
  final String id;
  final String name;
  final MessageType type;
  final bool isMine;
  final bool isRead;
  final String image;
  final bool showDate;
  final DateTime sentDate;
  final String message;

  const ChatMessageItem({
    @required this.id,
    @required this.name,
    @required this.type,
    @required this.isMine,
    @required this.isRead,
    @required this.image,
    @required this.showDate,
    @required this.sentDate,
    @required this.message,
  });

  @override
  List get props => [
    id,
    name,
    type,
    isMine,
    isRead,
    image,
    showDate,
    sentDate,
    message,
  ];

  @override
  bool get stringify => true;
}