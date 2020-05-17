import 'dart:async';

import 'package:tuple/tuple.dart';

import '../../bloc/bloc_provider.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../models/old/group_entity.dart';
import './chat_tabs_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

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
  }) {
    ///
    /// Assert
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');

    /// 
    /// Stream controllers
    /// 
    

    ///
    /// Streams
    ///
    final chatTabsState$ = _getChatLists(
      userBloc,
      groupRepository,
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
      return groupRepository.get()
        .map((entities) {
          return _entitiesToGroupItems(entities);
        })
        .map((groupItems) {
          Tuple3 sorted = _sortGroups(groupItems, loginState.uid);

          return _kInitialChatState.copyWith(
            messages: sorted.item1,
            chatRooms: sorted.item2,
            groups: sorted.item3,
            isLoading: false,
          );
        })
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
        name: entity.groupName,
        image: entity.groupImage,
        ownerId: entity.uid,
        byAdmin: entity.byAdmin,
        isPrivate: entity.isGroupPrivate,
      );
    }).toList();
  }

  static Stream<ChatTabsState> _getChatLists(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        groupRepository,
      );
    });
  }

  static Tuple3 _sortGroups(
    List<GroupItem> groups,
    String uid,
  ) {
    return Tuple3(
      groups.where((group) => group.members.contains(uid)).toList(),
      groups.where((group) => group.byAdmin).where((group) => !group.isPrivate).toList(),
      groups.where((group) => group.ownerId == uid).toList(),
    );
  }
}