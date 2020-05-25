import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/old/trophy.dart';
import '../../models/old/user_entity.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../models/old/post_entity.dart';
import '../../pages/feed/feed_state.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_preview_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './trophies_state.dart';
import 'package:timeago/timeago.dart' as timeago;



const _kInitialTrophiesState = TrophiesState(
    isLoading: true,
    error: null,
    trophies: []
);

class TrophiesBloc implements BaseBloc {
  ///
  /// Input functions
  ///


  ///
  /// Output streams
  ///
  final ValueStream<TrophiesState> trophiesState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TrophiesBloc._({
    @required this.trophiesState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory TrophiesBloc({
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
    final trophiesState$ = _getConnections(
        userBloc,
        userId,
        userRepository
    ).publishValueSeeded(_kInitialTrophiesState);

    final subscriptions = <StreamSubscription>[
      trophiesState$.connect(),
    ];

    return TrophiesBloc._(
        trophiesState$: trophiesState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<TrophiesState> _toState(
      LoginState loginState,
      String userId,
      FirestoreUserRepository userRepository
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialTrophiesState.copyWith(
          error: TrophiesNotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository.getUserById(uid: userId ?? loginState.uid).map((entity){
        return _entityToTrophyItems(entity);
      })
      .map((trophies) {
        return _kInitialTrophiesState.copyWith(
          isLoading: false,
          trophies: trophies,
        );
      })
      .startWith(_kInitialTrophiesState)
      .onErrorReturnWith((e) {
        return _kInitialTrophiesState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialTrophiesState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<Trophy> _entityToTrophyItems(
    UserEntity entity,
  ) {
    return entity.treeTrophies;
  }

  static Stream<TrophiesState> _getConnections(
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