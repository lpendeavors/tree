import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/chat/firestore_chat_repository.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../bloc/bloc_provider.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/chat_entity.dart';
import '../../models/old/group_entity.dart';
import './chat_room_state.dart';

const _kInitialChatRoomState = ChatRoomState(
  error: null,
  isLoading: true,
  messages: [],
  details: null,
);

class ChatRoomBloc implements BaseBloc {
  /// 
  /// Input functions
  ///
  

  /// 
  /// Output streams
  ///
  final ValueStream<ChatRoomState> chatRoomState$;

  /// 
  /// Clean up
  /// 
  final void Function() _dispose;

  ChatRoomBloc._({
    @required this.chatRoomState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ChatRoomBloc({
    @required UserBloc userBloc,
    @required FirestoreChatRepository chatRepository,
    @required FirestoreGroupRepository groupRepository,
    @required String roomId,
  }) {
    /// 
    /// Assert 
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(chatRepository != null, 'chatRepository cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(roomId != null, 'roomId cannot be null');

    /// 
    /// Stream controllers
    ///
    

    /// 
    /// Streams
    ///
    final chatRoomState$ = _getChatRoomContent(
      userBloc,
      groupRepository,
      chatRepository,
      roomId,
    ).publishValueSeeded(_kInitialChatRoomState);

    final subscriptions = <StreamSubscription>[
      chatRoomState$.connect(),
    ];

    return ChatRoomBloc._(
      chatRoomState$: chatRoomState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose;

  static Stream<ChatRoomState> _toState(
    LoginState loginState,
    FirestoreChatRepository chatRepository,
    FirestoreGroupRepository groupRepository,
    String roomId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialChatRoomState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(
        groupRepository.getById(groupId: roomId),
        chatRepository.getByGroup(roomId),
        (group, chats) {


          return _kInitialChatRoomState.copyWith(
            isLoading: false,
            details: _entityToChatRoomItem(group),
            messages: _entitiesToChatMessageItems(chats, loginState.uid),
          );
        }
      )
      .startWith(_kInitialChatRoomState)
      .onErrorReturnWith((e) {
        return _kInitialChatRoomState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialChatRoomState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static ChatRoomItem _entityToChatRoomItem(
    GroupEntity entity,
  ) {
    return ChatRoomItem(
      id: entity.documentId,
      isConversation: entity.isConversation,
      isGroup: entity.isGroup,
      members: entity.groupMembers,
      image: entity.image,
      groupImage: entity.groupImage,
      name: entity.groupName,
    );
  }

  static List<ChatMessageItem> _entitiesToChatMessageItems(
    List<ChatEntity> entities,
    String uid,
  ) {
    entities.sort((a, b) => b.time.compareTo(a.time));
    return entities.map((entity) {
      return ChatMessageItem(
        id: entity.documentId,
        type: MessageType.values[entity.type],
        isMine: entity.ownerId == uid,
        isRead: entity.readBy.contains(uid),
        showDate: entity.showDate,
        sentDate: DateTime.fromMillisecondsSinceEpoch(entity.time),
        message: entity.message,
        image: entity.image,
        name: entity.fullName,
      );
    }).toList();
  }

  static Stream<ChatRoomState> _getChatRoomContent(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    FirestoreChatRepository chatRepository,
    String roomId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        chatRepository,
        groupRepository,
        roomId,
      );
    });
  }
}