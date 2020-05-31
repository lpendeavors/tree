import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/user_bloc/user_bloc.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';

import '../../../bloc/bloc_provider.dart';
import '../../../pages/settings/profile/profile_settings_state.dart';

const _kInitialProfileSettingsState = ProfileSettingsState(
  isLoading: true,
  error: false,
  firstName: null,
  lastName: null,
  phoneNumber: null
);

class ProfileSettingsBloc implements BaseBloc{
  ///
  /// Input functions
  ///
  final void Function(String string) setFirstName;
  final void Function(String string) setLastName;
  final void Function(String string) setPhoneNumber;
  final void Function() saveChanges;

  ///
  /// Output streams
  ///
  final ValueStream<ProfileSettingsState> settingState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ProfileSettingsBloc._({
    @required this.setFirstName,
    @required this.setLastName,
    @required this.setPhoneNumber,
    @required this.saveChanges,
    @required this.settingState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ProfileSettingsBloc({
    @required int index,
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
  }){
    ///
    /// Assert
    ///
    assert(index != null, 'index cannot be null');
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Controllers
    ///
    final setFirstNameController = BehaviorSubject<String>();
    final setLastNameController = BehaviorSubject<String>();
    final setPhoneNumberController = BehaviorSubject<String>();
    final saveChangesController = PublishSubject<void>();

    saveChangesController.exhaustMap(
      (_) => saveProfileChanges(
        setFirstNameController.value,
        setLastNameController.value,
        setPhoneNumberController.value,
        userRepository,
      )
    ).publish();

    ///
    /// Streams
    ///
    final settingState$ = _getSettings(
        userBloc,
        userRepository
    ).publishValueSeeded(_kInitialProfileSettingsState);

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      settingState$.connect(),
    ];

    final controllers = <StreamController>[
      setFirstNameController,
      setLastNameController,
      setPhoneNumberController,
      saveChangesController
    ];

    return ProfileSettingsBloc._(
      settingState$: settingState$,
      setFirstName: setFirstNameController.add,
      setLastName: setLastNameController.add,
      setPhoneNumber: setPhoneNumberController.add,
      saveChanges: () => saveChangesController.add(null),
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<ProfileSettingsState> _toSettingsState(
      LoginState loginState,
      FirestoreUserRepository userRepository,
      ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialProfileSettingsState.copyWith(
          error: SettingsNotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository.getUserById(uid: loginState.uid).map((user){
        return _kInitialProfileSettingsState.copyWith(
          firstName: user.firstName,
          lastName: user.lastName,
          phoneNumber: user.phoneNumber
        );
      })
      .startWith(_kInitialProfileSettingsState)
      .onErrorReturnWith((e) {
        return _kInitialProfileSettingsState.copyWith(
          error: e,
          isLoading: false
        );
      });
    }

    return Stream.value(
      _kInitialProfileSettingsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static Stream<ProfileSettingsState> _getSettings(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toSettingsState(
        loginState,
        userRepository,
      );
    });
  }

  static saveProfileChanges(
    String firstName,
    String lastName,
    String phoneNumber,
    FirestoreUserRepository userRepository
  ){

  }
}