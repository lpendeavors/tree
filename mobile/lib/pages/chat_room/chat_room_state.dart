import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../models/old/group_member.dart';

///
/// Enums
///
enum MessageType { text, image, gif, doc, video }
enum MessageOption { delete, copy }

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
  final Object error;
  const ChatMessageAddedError(this.error);
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

class MessageError {
  const MessageError();
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
  final bool isMuted;
  final bool isAdmin;

  const ChatRoomItem({
    @required this.id,
    @required this.isGroup,
    @required this.isConversation,
    @required this.members,
    @required this.image,
    @required this.groupImage,
    @required this.name,
    @required this.isMuted,
    @required this.isAdmin,
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
        isMuted,
        isAdmin,
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
  final String userId;
  final List<String> members;
  final String gif;

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
    @required this.userId,
    @required this.members,
    @required this.gif,
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
        userId,
        members,
        gif,
      ];

  @override
  bool get stringify => true;
}

@immutable
class MemberItem extends Equatable {
  final String name;
  final String image;
  final String id;

  const MemberItem({
    @required this.name,
    @required this.image,
    @required this.id,
  });

  @override
  List get props => [name, image, id];

  @override
  bool get stringify => true;
}
