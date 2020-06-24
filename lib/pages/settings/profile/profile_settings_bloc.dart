import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/old/user_entity.dart';
import '../../../data/user/firestore_user_repository.dart';
import '../../../user_bloc/user_bloc.dart';
import '../../../user_bloc/user_login_state.dart';
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
  city: "",
  address: "",
  type: 0,
  status: 0,
  emailAddress: "",
  churchInfo: null
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
  final void Function(String string) setCity;
  final void Function(String string) setAddress;
  final void Function(String string) countryCodeChanged;
  final void Function() saveChanges;
  final void Function(UserEntity entity) setChurch;
  final void Function(String string) setUnknownChurch;
  final void Function(bool church) setNoChurch;
  final void Function(String churchId) setChurchId;

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
    @required this.setCity,
    @required this.setAddress,
    @required this.saveChanges,
    @required this.countryCodeChanged,
    @required this.setChurch,
    @required this.setUnknownChurch,
    @required this.setNoChurch,
    @required this.setChurchId,
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
    final setCityController = BehaviorSubject<String>();
    final setAddressController = BehaviorSubject<String>();
    final saveChangesController = PublishSubject<void>();
    final countryCodeController = BehaviorSubject<String>.seeded('+1');
    final setChurchController = BehaviorSubject<UserEntity>();
    final setUnknownChurchController = BehaviorSubject<String>();
    final setNoChurchController = BehaviorSubject<bool>();
    final setChurchIdController = BehaviorSubject<String>();

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
        setCityController.value,
        setAddressController.value,
        countryCodeController.value,
        setChurchController.value,
        setUnknownChurchController.value,
        setNoChurchController.value,
        setChurchIdController.value,
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
      setCityController,
      setAddressController,
      saveChangesController,
      countryCodeController,
      setChurchController,
      setUnknownChurchController,
      setNoChurchController,
      setChurchIdController
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
      setCity: setCityController.add,
      setAddress: setAddressController.add,
      countryCodeChanged: countryCodeController.add,
      setChurch: setChurchController.add,
      setUnknownChurch: setUnknownChurchController.add,
      setNoChurch: setNoChurchController.add,
      setChurchId: setChurchIdController.add,
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
          isPublic: user.isPublic && user.status == 0,
          title: user.title,
          bio: user.aboutMe,
          city: user.city,
          address: user.businessAddress,
          status: user.status,
          isLoading: false,
          emailAddress: user.email,
          churchInfo: user.churchInfo
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
    String city,
    String address,
    String countryCode,
    UserEntity church,
    String unknownChurch,
    bool noChurch,
    String churchId,
    FirestoreUserRepository userRepository
  ) async* {
    Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'fullName': '$firstName $lastName',
      'phoneNo': '$countryCode$phoneNo',
      'relationStatus': relationship,
      'title': title,
      'aboutMe': aboutMe,
      'city': city,
      'businessAddress': address,
    };

    print("${church.uid.substring(0, 7).toUpperCase()} ${churchId}");
    if(church != null && church.uid.substring(0, 7).toUpperCase() == churchId){
      data['churchInfo'] = {
        'churchName': church.churchName,
        'churchAddress': church.churchAddress,
        'churchDenomination': church.churchDenomination
      };
    }else if(unknownChurch != null) {
      data['churchInfo'] = {
        'churchName': unknownChurch,
        'churchAddress': null,
        'churchDenomination': null
      };
    }else if(noChurch == true){
      data['churchInfo'] = null;
    }


    if(isPublic != null && isPublic){
      data['isPublic'] = isPublic;
      data['status'] = 0;
    }

    LoginState state = userBloc.loginState$.value;
    if(state is LoggedInUser){
      await userRepository.updateUserData(state.uid, data);
    }

    yield SettingsMessageSuccess();
  }
}