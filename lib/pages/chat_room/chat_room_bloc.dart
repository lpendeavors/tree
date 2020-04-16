import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/group_entity.dart';
import '../chat/chat_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialRoomListState = RoomListState(
    error: null,
    isLoading: true,
    roomItems: []
);

class ChatBloc implements BaseBloc {

  ///
  /// Output streams
  ///
  final ValueStream<RoomListState> roomListState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ChatBloc._({
    @required this.roomListState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ChatBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
  }){
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final feedListState$ = _getRoomList(
      userBloc,
      postRepository,
    ).publishValueSeeded(_kInitialRoomListState);

    final subscriptions = <StreamSubscription>[
      feedListState$.connect()
    ];

    return ChatBloc._(
        roomListState$: feedListState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        }
    );
  }

  @override
  void dispose() => _dispose;

  static Stream<RoomListState> _toState(
      LoginState loginState,
      FirestorePostRepository postRepository,
  ){
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialRoomListState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return postRepository.posts(uid: loginState.uid)
          .map((entities) {
        return _entitiesToRoomItems(
          entities,
          loginState.uid,
        );
      })
          .map((roomItems) {
        return _kInitialRoomListState.copyWith(
          roomItems: roomItems,
          isLoading: false,
        );
      })
          .startWith(_kInitialRoomListState)
          .onErrorReturnWith((e) {
        return _kInitialRoomListState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialRoomListState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<RoomItem> _entitiesToRoomItems(
      List<GroupEntity> entities,
      String uid,
  ){
    return entities.map((entity) {
      var roomTitle = null;
      return RoomItem(
        id: entity.documentId,
        imageUrl: entity.image,
        roomTitle: entity.churchName ?? entity.fullName,
        previewText: "Preview Text",
        chatTime: "Time"
      );
    }).toList();
  }

  static Stream<RoomListState> _getRoomList(
      UserBloc userBloc,
      FirestorePostRepository postRepository,
  ){}
}