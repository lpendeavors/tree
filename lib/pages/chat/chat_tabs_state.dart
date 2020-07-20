import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../models/old/group_member.dart';

///
/// Error
///
@immutable
abstract class ChatTabsError {}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class ChatTabsState extends Equatable {
  final List<MessageItem> messages;
  final List<GroupItem> chatRooms;
  final List<GroupItem> groups;
  final bool isLoading;
  final Object error;

  const ChatTabsState({
    @required this.messages,
    @required this.chatRooms,
    @required this.groups,
    @required this.isLoading,
    @required this.error,
  });

  ChatTabsState copyWith({messages, chatRooms, groups, isLoading, error}) {
    return ChatTabsState(
      messages: messages ?? this.messages,
      chatRooms: chatRooms ?? this.chatRooms,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        messages,
        chatRooms,
        groups,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}

@immutable
class GroupItem extends Equatable {
  final String id;
  final bool isRoom;
  final bool isGroup;
  final String image;
  final String name;
  final bool isConversation;
  final bool byAdmin;
  final List<GroupMember> members;
  final String ownerId;
  final bool isPrivate;
  final bool isChurch;

  const GroupItem({
    @required this.id,
    @required this.isRoom,
    @required this.isGroup,
    @required this.image,
    @required this.name,
    @required this.isConversation,
    @required this.byAdmin,
    @required this.members,
    @required this.ownerId,
    @required this.isPrivate,
    @required this.isChurch,
  });

  @override
  List get props => [
        id,
        name,
        isConversation,
        isRoom,
        isGroup,
        image,
        members,
        byAdmin,
        ownerId,
        isPrivate,
        isChurch,
      ];

  @override
  bool get stringify => true;
}

@immutable
class MessageItem extends Equatable {
  final String id;
  final String name;
  final String image;
  final String message;
  final bool isRoom;
  final bool isGroup;
  final bool isConversation;
  final List<String> members;
  final DateTime sentDate;
  final String roomId;
  final bool isRead;
  final bool isMine;

  const MessageItem({
    @required this.id,
    @required this.name,
    @required this.image,
    @required this.message,
    @required this.isRoom,
    @required this.isGroup,
    @required this.isConversation,
    @required this.members,
    @required this.sentDate,
    @required this.roomId,
    @required this.isRead,
    @required this.isMine,
  });

  @override
  List get props => [
        id,
        name,
        image,
        message,
        isRoom,
        isGroup,
        isConversation,
        members,
        sentDate,
        roomId,
        isRead,
        isMine,
      ];

  @override
  bool get stringify => true;
}
