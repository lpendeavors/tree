import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './tag_connections_state.dart';

const _kInitialTagConnectionsState = TagConnectionsState(
  connections: [],
  isLoading: true,
  error: null,
);

class TagConnectionsBloc extends BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final ValueStream<TagConnectionsState> tagConnectionsState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TagConnectionsBloc._({
    @required this.tagConnectionsState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory TagConnectionsBloc({
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final tagConnectionsState$ = _getConnections(
      userBloc,
      userRepository,
    ).publishValueSeeded(_kInitialTagConnectionsState);

    final subscriptions = <StreamSubscription>[
      tagConnectionsState$.connect(),
    ];

    return TagConnectionsBloc._(
        tagConnectionsState$: tagConnectionsState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  dispose() => _dispose();

  static Stream<TagConnectionsState> _toState(
    LoginState loginState,
    FirestoreUserRepository userRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialTagConnectionsState.copyWith(
          error: 'NotLoggedInError',
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository
          .getMyConnections(loginState.connections)
          .map((connections) {
            return _kInitialTagConnectionsState.copyWith(
              connections: _entitiesToConnectionItems(connections),
              isLoading: false,
            );
          })
          .startWith(_kInitialTagConnectionsState)
          .onErrorReturnWith((e) {
            return _kInitialTagConnectionsState.copyWith(
              isLoading: false,
              error: e,
            );
          });
    }

    return Stream.value(
      _kInitialTagConnectionsState.copyWith(
        isLoading: false,
        error: 'Dont know loginState=$loginState',
      ),
    );
  }

  static List<ConnectionItem> _entitiesToConnectionItems(
    List<UserEntity> entities,
  ) {
    return entities.map((entity) {
      return ConnectionItem(
        id: entity.id,
        name: entity.isChurch ? entity.churchName : entity.fullName,
        image: entity.image ?? '',
      );
    }).toList();
  }

  static Stream<TagConnectionsState> _getConnections(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        userRepository,
      );
    });
  }
}
