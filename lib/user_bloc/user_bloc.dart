import 'dart:async';

import '../bloc/bloc_provider.dart';
import '../data/user/firestore_user_repository.dart';
import '../models/old/user_entity.dart';
import '../user_bloc/user_login_state.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc implements BaseBloc {
  ///
  /// Sinks
  ///
  final Sink<void> signOut;

  ///
  /// Streams
  ///
  final ValueStream<LoginState> loginState$;
  final Stream<UserMessage> message$;

  ///
  /// Cleanup
  ///
  final void Function() _dispose;

  factory UserBloc(FirestoreUserRepository userRepository) {
    final signOutController = PublishSubject<void>(sync: true);

    final user$ = userRepository.user()
      .map(_toLoginState)
      .distinct()
      .publishValueSeeded(const Unauthenticated());

    final signOutMessage$ = signOutController.exhaustMap((_) {
      return userRepository.signOut()
        .asStream()
        .doOnError((e) => print('[DEBUG] logout error=$e'))
        .onErrorReturnWith((e) => UserLogoutMessageError(e))
        .map((_) => const UserLogoutMessageSuccess());
    }).publish();

    final subscriptions = <StreamSubscription<dynamic>>[
      user$.connect(),
      signOutMessage$.connect(),
    ];

    return UserBloc._(
      () {
        signOutController.close();
        subscriptions.forEach((subscription) => subscription.cancel());
      },
      user$,
      signOutController,
      signOutMessage$,
    );
  }

  UserBloc._(
    this._dispose,
    this.loginState$,
    this.signOut,
    this.message$,
  );

  @override
  void dispose() => _dispose();

  static LoginState _toLoginState(UserEntity userEntity) {
    if (userEntity == null) {
      return const Unauthenticated();
    }

    return LoggedInUser(
      fullName: "${userEntity.firstName} ${userEntity.lastName}",
      email: userEntity.email,
      uid: userEntity.id,
      chatList: userEntity.myChatsList13 ?? [],
    );
  }
}