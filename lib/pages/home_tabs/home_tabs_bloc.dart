import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/models/old/chat_entity.dart';
import '../../data/chat/firestore_chat_repository.dart';
import '../../data/request/firestore_request_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../bloc/bloc_provider.dart';
import './home_tabs_state.dart';

const _kInitialHomeTabsState = HomeTabsState(
  hasMessages: false,
  hasRequests: false,
  isLoading: true,
  error: null,
);

class HomeTabsBloc extends BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final ValueStream<HomeTabsState> homeTabsState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  HomeTabsBloc._({
    @required this.homeTabsState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory HomeTabsBloc({
    @required UserBloc userBloc,
    @required FirestoreRequestRepository requestRepository,
    @required FirestoreChatRepository chatRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(requestRepository != null, 'requestRepository cannot be null');
    assert(chatRepository != null, 'chatRepository cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final homeTabsState$ = _getTabsState(
      userBloc,
      requestRepository,
      chatRepository,
    ).publishValueSeeded(_kInitialHomeTabsState);

    final subscriptions = <StreamSubscription>[
      homeTabsState$.connect(),
    ];

    return HomeTabsBloc._(
        homeTabsState$: homeTabsState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<HomeTabsState> _toState(
    LoginState loginState,
    FirestoreRequestRepository requestRepository,
    FirestoreChatRepository chatRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialHomeTabsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.combineLatest2(Stream.value(List<UserEntity>()),
          chatRepository.getByUser(uid: loginState.uid), (requests, chats) {
        var hasNewRequests = loginState.receivedRequests
                .where((r) => !loginState.connections.contains(r))
                .toList()
                .length >
            0;

        return _kInitialHomeTabsState.copyWith(
          hasMessages: _hasNewChats(chats, loginState.uid),
          hasRequests: hasNewRequests,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialHomeTabsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static Stream<HomeTabsState> _getTabsState(
    UserBloc userBloc,
    FirestoreRequestRepository requestRepository,
    FirestoreChatRepository chatRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        requestRepository,
        chatRepository,
      );
    });
  }

  static bool _hasNewChats(
    List<ChatEntity> chats,
    String uid,
  ) {
    var newChats = List<ChatEntity>();
    chats.forEach((chat) {
      if (!chat.readBy.contains(uid) && chat.parties.contains(uid)) {
        newChats.add(chat);
      }
    });

    return newChats.length > 0;
  }
}
