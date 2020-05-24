import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/old/church_info.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './profile_state.dart';


const _kInitialProfileState = ProfileState(
  profile: null,
  isLoading: true,
  error: false,
);

class ProfileBloc implements BaseBloc {
  ///
  /// Input functions
  /// 
  

  ///
  /// Output streams
  /// 
  final ValueStream<ProfileState> profileState$;

  ///
  /// Clean up
  /// 
  final void Function() _dispose;

  ProfileBloc._({
    @required this.profileState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ProfileBloc({
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
    @required String userId,
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
    final profileState$ = _getProfile(
      userBloc,
      userRepository,
      userId,
    ).publishValueSeeded(_kInitialProfileState);

    final subscriptions = <StreamSubscription>[
      profileState$.connect(),
    ];

    return ProfileBloc._(
      profileState$: profileState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<ProfileState> _toState(
    LoginState loginState,
    FirestoreUserRepository userRepository,
    String userId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialProfileState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository.getUserById(uid: userId)
        .map((entity) {
          return _entityToProfileItem(
            entity,
            loginState,
          );
        })
        .map((profileItem) {
          return _kInitialProfileState.copyWith(
            profile: profileItem,
            isLoading: false,
          );
        })
        .startWith(_kInitialProfileState)
        .onErrorReturnWith((e) {
          return _kInitialProfileState.copyWith(
            error: e,
            isLoading: false,
          );
        });
    }

    return Stream.value(
      _kInitialProfileState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static ProfileItem _entityToProfileItem(
    UserEntity entity,
    LoginState loginState,
  ) {
    return ProfileItem(
      id: entity.documentId,
      photo: entity.image,
      isChurch: entity.isChurch,
      isVerified: entity.isVerified ?? false,
      fullName: entity.fullName,
      churchName: entity.churchName ?? "NONE",
      connections: entity.connections,
      shares: entity.shares ?? [],
      trophies: entity.treeTrophies,
      type: entity.type,
      churchDenomination: entity.churchDenomination ?? 'NONE',
      churchAddress: entity.churchAddress ?? 'NONE',
      aboutMe: entity.aboutMe ?? 'Hey I am new to Tree',
      title: entity.title ?? 'NONE',
      city: entity.city ?? 'NONE',
      relationStatus: entity.relationStatus ?? 'NONE',
      churchInfo: entity.churchInfo
    );
  }

  static Stream<ProfileState> _getProfile(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
    String userId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        userRepository,
        userId,
      );
    });
  }
}