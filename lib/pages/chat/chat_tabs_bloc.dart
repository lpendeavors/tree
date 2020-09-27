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
        });
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
      print('uid=${loginState.uid}');
      return Rx.combineLatest5(
          chatRepository.getByUser(uid: loginState.uid),
          groupRepository.getRoomsByUser(loginState.uid),
          groupRepository.getDefaultRooms(),
          groupRepository.getGroupsByUser(loginState.uid),
          (loginState.churchId != null)
              ? groupRepository.getById(
                  groupId: loginState.isChurch
                      ? loginState.uid
                      : loginState.churchId)
              : Stream.value(null),
          (chats, myRooms, defaultRooms, groups, church) {
        return _kInitialChatState.copyWith(
          isLoading: false,
          messages: _entitiesToMessageItems(chats, loginState.uid),
          chatRooms: _filterRooms(myRooms, defaultRooms, church, loginState),
          groups: _entitiesToGroupItems(groups, false),
        );
      }).startWith(_kInitialChatState).onErrorReturnWith((e) {
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
    bool isDefault,
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
        isChurch: false,
        isDefault: isDefault,
      );
    }).toList();
  }

  static List<MessageItem> _entitiesToMessageItems(
    List<ChatEntity> entities,
    String uid,
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
        members: entity.parties,
        isRoom: entity.isRoom ?? false,
        sentDate: DateTime.fromMillisecondsSinceEpoch(entity.time),
        roomId: entity.chatId,
        isRead: (entity.readBy ?? []).contains(uid),
        isMine: entity.ownerId == uid,
        isConversation:
            (!(entity.isRoom ?? false) && entity.parties.length > 2),
        isGroup: false,
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

  static List<GroupItem> _filterRooms(
    List<GroupEntity> myRooms,
    List<GroupEntity> defaultRooms,
    GroupEntity church,
    LoginState loginState,
  ) {
    var user = loginState as LoggedInUser;
    var rooms = _entitiesToGroupItems(defaultRooms, true);
    var mine = _entitiesToGroupItems(myRooms, false);
    var all = List<GroupItem>();

    if (church != null) {
      var churchGroup = _entitiesToGroupItems([church], false);
      all.addAll(churchGroup);
    }

    if (user.isYouth) {
      rooms =
          rooms.where((r) => r.name.toLowerCase().contains('youth')).toList();
    } else {
      rooms =
          rooms.where((r) => !r.name.toLowerCase().contains('youth')).toList();
    }

    all.addAll(mine);
    all.addAll(rooms);

    return all.toSet().toList();
  }
}
