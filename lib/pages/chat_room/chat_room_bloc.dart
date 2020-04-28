import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/room/firestore_room_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/new/room_entity.dart';
import '../chat/chat_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialRoomListState = RoomListState(
    error: null,
    isLoading: true,
    roomItems: []
);

class ChatRoomBloc implements BaseBloc {

  ///
  /// Output streams
  ///
  final ValueStream<RoomListState> roomListState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ChatRoomBloc._({
    @required this.roomListState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ChatRoomBloc({
    @required UserBloc userBloc,
    @required FirestoreRoomRepository roomRepository,
  }){
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(roomRepository != null, 'postRepository cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final roomListState$ = _getRoomList(
      userBloc,
      roomRepository,
    ).publishValueSeeded(_kInitialRoomListState);

    final subscriptions = <StreamSubscription>[
      roomListState$.connect()
    ];

    return ChatRoomBloc._(
        roomListState$: roomListState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        }
    );
  }

  @override
  void dispose() => _dispose;

  static Stream<RoomListState> _toState(
      LoginState loginState,
      FirestoreRoomRepository roomRepository,
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
      return roomRepository.rooms(uid: loginState.uid)
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
      List<RoomEntity> entities,
      String uid,
  ){
    return entities.map((entity) {
      print(entity.toString());
      return RoomItem(
        id: entity.documentId,
        imageUrl: entity.photo,
        roomTitle: entity.title,
        previewText: "Preview Text",
        chatTime: "Time"
      );
    }).toList();
  }

  static Stream<RoomListState> _getRoomList(
      UserBloc userBloc,
      FirestoreRoomRepository roomRepository,
  ){
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        roomRepository,
      );
    });
  }
}