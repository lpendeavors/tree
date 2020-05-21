import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// 
/// Message
///
abstract class ChatRoomDetailsMessage {
  const ChatRoomDetailsMessage();
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
class ChatRoomDetailsState extends Equatable {
  final ChatRoomDetailsItem chatRoomDetails;
  final List<ChatRoomPostItem> chatRoomPosts;
  final bool isLoading;
  final Object error;

  const ChatRoomDetailsState({
    @required this.chatRoomDetails,
    @required this.chatRoomPosts,
    @required this.isLoading,
    @required this.error,
  });

  ChatRoomDetailsState copyWith({chatRoomDetails, chatRoomPosts, isLoading, error}) {
    return ChatRoomDetailsState(
      chatRoomDetails: chatRoomDetails ?? this.chatRoomDetails,
      chatRoomPosts: chatRoomPosts ?? this.chatRoomPosts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    chatRoomDetails,
    chatRoomPosts,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatRoomDetailsItem extends Equatable {
  final String id;
  final String name;
  final bool isGroup;
  final bool isConversation;
  final bool isAdmin;
  final String image;
  final bool wallEnabled;
  final List<ChatRoomMemberItem> members;
  final String description;

  const ChatRoomDetailsItem({
    @required this.id,
    @required this.name,
    @required this.isGroup,
    @required this.isAdmin,
    @required this.isConversation,
    @required this.image,
    @required this.members,
    @required this.description,
    @required this.wallEnabled,
  });

  @override
  List get props => [
    id, 
    name,
    isGroup,
    isAdmin,
    isConversation,
    image,
    members,
    description,
    wallEnabled,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatRoomMemberItem extends Equatable {
  final String id;
  final String image;

  const ChatRoomMemberItem({
    @required this.id,
    @required this.image,
  });

  @override
  List get props => [
    id,
    image,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ChatRoomPostItem extends Equatable {
  final String id;

  const ChatRoomPostItem({
    @required this.id,
  });

  @override
  List get props => [
    id
  ];

  @override
  bool get stringify => true;
}