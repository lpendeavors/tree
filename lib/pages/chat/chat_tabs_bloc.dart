import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../data/chat/firestore_chat_repository.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../models/old/group_entity.dart';
import '../../models/old/chat_entity.dart';
import './chat_tabs_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

const _kInitialChatState = ChatTabsState(
  error: null,
  isLoading: true,
  messages: [],
  chatRooms: [],
  groups: [],
);

class ChatTabsBloc implements BaseBloc {
  ///
  /// Input functions
  /// 
  
  /// 
  /// Output streams
  /// 
  final ValueStream<ChatTabsState> chatTabsState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ChatTabsBloc._({
    @required this.chatTabsState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ChatTabsBloc({
    @required UserBloc userBloc,
    @required FirestoreGroupRepository groupRepository,
    @required FirestoreChatRepository chatRepository,
  }) {
    ///
    /// Assert
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(chatRepository != null, 'chatRepository cannot be null');

    /// 
    /// Stream controllers
    /// 
    

    ///
    /// Streams
    ///
    final chatTabsState$ = _getChatLists(
      userBloc,
      groupRepository,
      chatRepository,
    ).publishValueSeeded(_kInitialChatState);

    final subscriptions = <StreamSubscription>[
      chatTabsState$.connect(),
    ];

    return ChatTabsBloc._(
      chatTabsState$: chatTabsState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<ChatTabsState> _toState(
    LoginState loginState,
    FirestoreGroupRepository groupRepository,
    FirestoreChatRepository chatRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialChatState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(
          chatRepository.getByUser(
            uid: loginState.uid, 
            chatIds: loginState.chatList.length > 0 
              ? loginState.chatList.map((e) => e.chatId).toList()
              : []
          ),
          groupRepository.get(),
          (chats, groups) {
            Tuple2 sortedGroups = _sortGroups(
              _entitiesToGroupItems(groups), 
              loginState.uid
            );

            return _kInitialChatState.copyWith(
              isLoading: false,
              messages: _entitiesToMessageItems(chats),
              chatRooms: sortedGroups.item1,
              groups: sortedGroups.item2,
            );
          }
        )
        .startWith(_kInitialChatState)
        .onErrorReturnWith((e) {
          return _kInitialChatState.copyWith(
            error: e,
            isLoading: false,
          );
        });
    }

    return Stream.value(
      _kInitialChatState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }
  
  static List<GroupItem> _entitiesToGroupItems(
    List<GroupEntity> entities,
  ) {
    return entities.map((entity) {
      return GroupItem(
        id: entity.documentId,
        isConversation: entity.isConversation,
        isGroup: entity.isGroup,
        isRoom: entity.isRoom,
        members: entity.groupMembers,
        name: entity.groupName ?? "",
        image: entity.groupImage,
        ownerId: entity.uid,
        byAdmin: entity.byAdmin,
        isPrivate: entity.isGroupPrivate,
      );
    }).toList();
  }

  static List<MessageItem> _entitiesToMessageItems(
    List<ChatEntity> entities,
  ) {
    var grouped = groupBy(entities, (e) {
      var entity = e as ChatEntity;
      return entity.chatId;
    });

    var lastMessages = List<ChatEntity>();
    grouped.forEach((key, messageList) {
      messageList.sort((a, b) => a.time.compareTo(b.time));
      lastMessages.add(messageList.last);
    });

    lastMessages.sort((a, b) => b.time.compareTo(a.time));

    return lastMessages.map((entity) {
      return MessageItem(
        id: entity.documentId,
        name: entity.fullName,
        message: entity.message,
        image: entity.image,
        isConversation: false,
        members: entity.parties,
        isRoom: entity.isRoom,
        isGroup: false,
        sentDate: DateTime.fromMillisecondsSinceEpoch(entity.time),
        roomId: entity.chatId,
      );
    }).toList();
  }

  static Stream<ChatTabsState> _getChatLists(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    FirestoreChatRepository chatRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        groupRepository,
        chatRepository,
      );
    });
  }

  static Tuple2 _sortGroups(
    List<GroupItem> groups,
    String uid,
  ) {
    return Tuple2(
      groups
        .where((group) => group.byAdmin)
        .where((group) => group.isPrivate != true)
        .toList(),
      groups
        .where((group) => !group.byAdmin)
        .where((group) => group.isGroup)
        .where((group) => (group.image ?? "").isNotEmpty)
        .toList(),
    );
  }
}