import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
  final Function(String) mute;
  final Function(String) updateToken;

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

    final user$ = userRepository
        .user()
        .map(_toLoginState)
        .distinct()
        .publishValueSeeded(const Unauthenticated());

    final signOutMessage$ = signOutController.exhaustMap((_) {
      return userRepository
          .signOut()
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
      (id) async {
        await _mute(userRepository, user$.value, id);
      },
      (token) async {
        await _saveToken(userRepository, user$.value, token);
      },
    );
  }

  UserBloc._(
    this._dispose,
    this.loginState$,
    this.signOut,
    this.message$,
    this.mute,
    this.updateToken,
  );

  @override
  void dispose() => _dispose();

  static LoginState _toLoginState(UserEntity userEntity) {
    if (userEntity == null) {
      return const Unauthenticated();
    }

    print(userEntity.uid);

    return LoggedInUser(
      fullName: (userEntity.isChurch ?? false)
          ? userEntity.churchName
          : "${userEntity.firstName} ${userEntity.lastName}",
      email: userEntity.email,
      uid: userEntity.id,
      isAdmin: userEntity.isAdmin ?? false,
      chatList: userEntity.myChatsList13 ?? [],
      image: userEntity.image,
      connections: userEntity.connections ?? [],
      church:
          userEntity.churchInfo != null ? userEntity.churchInfo.churchName : "",
      city: userEntity.city ?? "",
      token: userEntity.pushNotificationToken,
      isChurch: userEntity.isChurch ?? false,
      isVerified: userEntity.isVerified ?? false,
      churchId: userEntity.churchID,
      isYouth: false,
      mutedChats: userEntity.muted,
      isChurchUpdated: userEntity.isChurchUpdated ?? false,
      isProfileUpdated: userEntity.isProfileUpdated ?? false,
      receivedRequests: userEntity.receivedRequests ?? [],
      sentRequests: userEntity.sentRequests ?? [],
      isSuspended: userEntity.isSuspended ?? false,
    );
  }

  static Future<void> _mute(
    FirestoreUserRepository userRepository,
    LoginState loginState,
    String id,
  ) async {
    if (loginState is LoggedInUser) {
      await userRepository.mute(
        loginState.uid,
        id,
      );
    }
  }

  static Future<void> _saveToken(
    FirestoreUserRepository userRepository,
    LoginState loginState,
    String token,
  ) async {
    if (loginState is LoggedInUser) {
      await userRepository.updateToken(
        loginState.uid,
        token,
      );
    }
  }
}
