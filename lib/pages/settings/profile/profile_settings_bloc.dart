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
  isChurch: false,
  firstName: null,
  lastName: null,
  phoneNo: null,
  relationship: null,
  isPublic: false,
  title: null,
  bio: null,
  type: 0
);

class ProfileSettingsBloc implements BaseBloc{
  ///
  /// Input functions
  ///
  final void Function(String string) setFirstName;
  final void Function(String string) setLastName;
  final void Function(String string) setPhoneNumber;
  final void Function(String string) setRelationship;
  final void Function(bool value) setIsPublic;
  final void Function(String string) setTitle;
  final void Function(String string) setBio;
  final void Function() saveChanges;

  ///
  /// Output streams
  ///
  final ValueStream<ProfileSettingsState> settingState$;
  final Stream<ProfileSettingsMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ProfileSettingsBloc._({
    @required this.setFirstName,
    @required this.setLastName,
    @required this.setPhoneNumber,
    @required this.setRelationship,
    @required this.setIsPublic,
    @required this.setTitle,
    @required this.setBio,
    @required this.saveChanges,
    @required this.settingState$,
    @required this.message$,
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
    final setRelationshipController = BehaviorSubject<String>();
    final setIsPublicController = BehaviorSubject<bool>();
    final setTitleController = BehaviorSubject<String>();
    final setBioController = BehaviorSubject<String>();
    final saveChangesController = PublishSubject<void>();

    final message$ = saveChangesController.exhaustMap(
      (_) => saveProfileChanges(
        userBloc,
        setFirstNameController.value,
        setLastNameController.value,
        setPhoneNumberController.value,
        setRelationshipController.value,
        setIsPublicController.value,
        setTitleController.value,
        setBioController.value,
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
      message$.connect(),
      settingState$.connect(),
    ];

    final controllers = <StreamController>[
      setFirstNameController,
      setLastNameController,
      setPhoneNumberController,
      setRelationshipController,
      setIsPublicController,
      setTitleController,
      setBioController,
      saveChangesController
    ];

    return ProfileSettingsBloc._(
      settingState$: settingState$,
      message$: message$,
      setFirstName: setFirstNameController.add,
      setLastName: setLastNameController.add,
      setPhoneNumber: setPhoneNumberController.add,
      setRelationship: setRelationshipController.add,
      setIsPublic: setIsPublicController.add,
      setTitle: setTitleController.add,
      setBio: setBioController.add,
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
          isChurch: user.isChurch,
          firstName: user.firstName,
          lastName: user.lastName,
          phoneNo: user.phoneNo,
          relationship: user.relationStatus,
          type: user.type,
          isPublic: user.isPublic,
          title: user.title,
          bio: user.aboutMe,
          isLoading: false
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

  static Stream<ProfileSettingsMessage> saveProfileChanges(
    UserBloc userBloc,
    String firstName,
    String lastName,
    String phoneNo,
    String relationship,
    bool isPublic,
    String title,
    String aboutMe,
    FirestoreUserRepository userRepository
  ) async* {
    Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'fullName': '$firstName $lastName',
      'phoneNo': phoneNo,
      'relationStatus': relationship,
      'isPublic': isPublic,
      'title': title,
      'aboutMe': aboutMe
    };

    if(isPublic != null && isPublic){
      data['status'] = 0;
    }

    LoginState state = userBloc.loginState$.value;
    if(state is LoggedInUser){
      print('saving $data');
      await userRepository.updateUserData(state.uid, data);
    }

    yield SettingsMessageSuccess();
  }
}