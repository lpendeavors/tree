import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../models/old/post_entity.dart';
import '../../pages/feed/feed_state.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_preview_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './connections_state.dart';
import 'package:timeago/timeago.dart' as timeago;



const _kInitialConnectionsState = ConnectionsState(
    isLoading: true,
    error: null,
    connectionItems: []
);

class ConnectionsBloc implements BaseBloc {
  ///
  /// Input functions
  ///


  ///
  /// Output streams
  ///
  final ValueStream<ConnectionsState> connectionsState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ConnectionsBloc._({
    @required this.connectionsState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ConnectionsBloc({
    @required UserBloc userBloc,
    @required String userId,
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Streams
    ///
    final connectionsState$ = _getConnections(
        userBloc,
        userId,
        userRepository
    ).publishValueSeeded(_kInitialConnectionsState);

    final subscriptions = <StreamSubscription>[
      connectionsState$.connect(),
    ];

    return ConnectionsBloc._(
        connectionsState$: connectionsState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<ConnectionsState> _toState(
      LoginState loginState,
      String userId,
      FirestoreUserRepository userRepository
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialConnectionsState.copyWith(
          error: ConnectionsNotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository.getUserConnections(uid: userId ?? loginState.uid).map((entities){
        return _entitiesToConnectionItems(entities);
      })
      .map((connectionItems) {
        return _kInitialConnectionsState.copyWith(
          isLoading: false,
          connectionItems: connectionItems,
        );
      })
      .startWith(_kInitialConnectionsState)
      .onErrorReturnWith((e) {
        return _kInitialConnectionsState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialConnectionsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<ConnectionItem> _entitiesToConnectionItems(
    List<UserPreviewEntity> entities,
  ) {
    return entities.map((entity){
      return ConnectionItem(
        id: entity.documentId,
        uid: entity.uid,
        photo: entity.image ?? "",
        isChurch: entity.isChurch,
        fullName: entity.fullName,
        churchName: entity.churchName,
        aboutMe: entity.aboutMe ?? "Hey there! I am using Tree",
      );
    }).toList();
  }

  static Stream<ConnectionsState> _getConnections(
    UserBloc userBloc,
    String userId,
    FirestoreUserRepository userRepository
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
          loginState,
          userId,
          userRepository
      );
    });
  }
}