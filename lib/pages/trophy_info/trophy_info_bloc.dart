import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/old/trophy.dart';
import '../../models/old/user_entity.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './trophy_info_state.dart';



const _kInitialTrophyInfoState = TrophyInfoState(
  isLoading: true,
  error: null,
  trophy: null
);

class TrophyInfoBloc implements BaseBloc {
  ///
  /// Input functions
  ///


  ///
  /// Output streams
  ///
  final ValueStream<TrophyInfoState> trophyInfoState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TrophyInfoBloc._({
    @required this.trophyInfoState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory TrophyInfoBloc({
    @required UserBloc userBloc,
    @required String trophyKey,
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
    final trophyInfoState$ = _getTrophyInfo(
        userBloc,
        trophyKey,
        userRepository
    ).publishValueSeeded(_kInitialTrophyInfoState);

    final subscriptions = <StreamSubscription>[
      trophyInfoState$.connect(),
    ];

    return TrophyInfoBloc._(
        trophyInfoState$: trophyInfoState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<TrophyInfoState> _toState(
      LoginState loginState,
      String trophyKey,
      FirestoreUserRepository userRepository
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialTrophyInfoState.copyWith(
          error: TrophyInfoNotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository.getUserById(uid: loginState.uid).map((entity){
        return _entityToTrophyInfo(entity, trophyKey);
      })
      .map((trophy) {
        return _kInitialTrophyInfoState.copyWith(
          isLoading: false,
          trophy: trophy,
        );
      })
      .startWith(_kInitialTrophyInfoState)
      .onErrorReturnWith((e) {
        return _kInitialTrophyInfoState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialTrophyInfoState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static Trophy _entityToTrophyInfo(
    UserEntity entity,
    String trophyKey
  ) {
    return entity.treeTrophies.where((element) => element.trophyKey == trophyKey).toList()[0];
  }

  static Stream<TrophyInfoState> _getTrophyInfo(
    UserBloc userBloc,
    String trophyKey,
    FirestoreUserRepository userRepository
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
          loginState,
          trophyKey,
          userRepository
      );
    });
  }
}