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
  userEntity: null,
);

class ProfileSettingsBloc implements BaseBloc{
  ///
  /// Input functions
  ///
  final void Function(int type) setValidationType;

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

  final void Function(String churchName) setChurchName;
  final void Function(int type) setMinistryType;
  final void Function(String denomination) setChurchDenomination;
  final void Function(List<dynamic>) setLocationData;
  final void Function(String website) setChurchWebsite;
  final void Function(String parent) setParentChurch;

  ///
  /// Output streams
  ///
  final ValueStream<ProfileSettingsState> settingState$;
  final Stream<ProfileSettingsMessage> message$;

  final Stream<NoFirstNameError> firstNameError$;
  final Stream<NoLastNameError> lastNameError$;

  final Stream<NoChurchNameError> churchNameError$;
  final Stream<NoBioError> ministryError$;
  final Stream<NoWebsiteError> websiteError$;
  final Stream<NoParentChurchError> parentChurchError$;

  final Stream<NoCityError> cityError$;
  final Stream<NoChurchStateError> churchStateError$;
  final Stream<NoChurchError> churchError$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ProfileSettingsBloc._({
    @required this.setValidationType,
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
    @required this.setChurchName,
    @required this.setMinistryType,
    @required this.setChurchDenomination,
    @required this.setLocationData,
    @required this.setChurchWebsite,
    @required this.setParentChurch,
    @required this.settingState$,
    @required this.message$,

    @required this.firstNameError$,
    @required this.lastNameError$,
    @required this.churchNameError$,
    @required this.ministryError$,
    @required this.websiteError$,
    @required this.parentChurchError$,
    @required this.cityError$,
    @required this.churchStateError$,
    @required this.churchError$,
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
    final validationTypeController = BehaviorSubject<int>.seeded(0);

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
    final setChurchController = BehaviorSubject<UserEntity>.seeded(null);
    final setUnknownChurchController = BehaviorSubject<String>();
    final setNoChurchController = BehaviorSubject<bool>.seeded(null);
    final setChurchIdController = BehaviorSubject<String>();

    final setChurchNameController = BehaviorSubject<String>();
    final setMinistryTypeController = BehaviorSubject<int>();
    final setChurchDenominationController = BehaviorSubject<String>();
    final setLocationDataController = BehaviorSubject<List<dynamic>>();
    final setChurchWebsiteController = BehaviorSubject<String>();
    final setParentChurchController = BehaviorSubject<String>();

    ///
    /// Error Streams
    ///
    final firstNameError$ = setFirstNameController.map((name) {
      if (name.length > 0) return null;
      return NoFirstNameError();
    }).share();

    final lastNameError$ = setLastNameController.map((name) {
      if (name.length > 0) return null;
      return NoLastNameError();
    }).share();

    final churchNameError$ = setChurchNameController.map((name) {
      if (name.length > 0) return null;
      return NoChurchNameError();
    }).share();

    final bioError$ = setBioController.map((bio) {
      if (bio.length > 0) return null;
      return NoBioError();
    }).share();

    final websiteError$ = setChurchWebsiteController.map((site) {
      if (site.length > 0) return null;
      return NoWebsiteError();
    }).share();

    final parentChurchError$ = setParentChurchController.map((church) {
      if (church.length > 0) return null;
      return NoParentChurchError();
    }).share();

    final cityError$ = setCityController.map((city) {
      if (city.length > 0) return null;
      return NoCityError();
    }).share();

    final churchStateError$ = setNoChurchController.map((church) {
      if (church != null) return null;
      return NoChurchStateError();
    }).share();

    final churchError$ = setChurchController.map((church) {
      if (church != null) return null;
      return NoChurchError();
    }).share();

    ///
    /// Streams
    ///
    final settingState$ = _getSettings(
        userBloc,
        userRepository
    ).publishValueSeeded(_kInitialProfileSettingsState);

    final personal_personalFieldsAreValid$ = Rx.combineLatest(
        [
          firstNameError$,
          lastNameError$,
          cityError$,
          bioError$
        ], (allErrors) => allErrors.every((error) {
      print(error);
      return error == null;
    }));

    final personal_churchFieldsAreValid$ = Rx.combineLatest(
        [
          churchStateError$
        ], (allErrors) => allErrors.every((error) {
      print(error);
      return error == null;
    }));

    final personal_churchFieldsAreValid2$ = Rx.combineLatest(
        [
          churchStateError$,
          churchError$
        ], (allErrors) => allErrors.every((error) {
      print(error);
      return error == null;
    }));

    final church_personalFieldsAreValid$ = Rx.combineLatest(
      [
        firstNameError$,
        lastNameError$
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final church_churchFieldsAreValid$ = Rx.combineLatest(
        [
          churchNameError$,
          bioError$,
          websiteError$,
          parentChurchError$
        ], (allErrors) => allErrors.every((error) {
      print(error);
      return error == null;
    }));

    final validators = [
      personal_personalFieldsAreValid$,
      [personal_churchFieldsAreValid$, personal_churchFieldsAreValid2$],
      Stream.value(true),
      church_personalFieldsAreValid$,
      church_churchFieldsAreValid$,
      Stream.value(true)
    ];

    final message$ = saveChangesController
      .withLatestFrom(validationTypeController.value == 1 ? (validators[validationTypeController.value] as List)[setNoChurchController.value ? 1 : 0] : validators[validationTypeController.value], (_, bool isValid) {
        print(isValid);
        return isValid;
      })
      .where((isValid) => isValid)
      .exhaustMap((_) => saveProfileChanges(
        userBloc,
        validationTypeController.value,
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
        setChurchNameController.value,
        setMinistryTypeController.value,
        setChurchDenominationController.value,
        setLocationDataController.value,
        setChurchWebsiteController.value,
        setParentChurchController.value,
        userRepository,
      )
    ).publish();

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      message$.connect(),
      settingState$.connect()
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
      setChurchIdController,
      setChurchNameController,
      setMinistryTypeController,
      setChurchDenominationController,
      setLocationDataController,
      setChurchWebsiteController,
      setParentChurchController
    ];

    return ProfileSettingsBloc._(
        settingState$: settingState$,
        message$: message$,
        setValidationType: validationTypeController.add,
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
        setChurchName: setChurchNameController.add,
        setMinistryType: setMinistryTypeController.add,
        setChurchDenomination: setChurchDenominationController.add,
        setLocationData: setLocationDataController.add,
        setChurchWebsite: setChurchWebsiteController.add,
        setParentChurch: setParentChurchController.add,
        saveChanges: () => saveChangesController.add(null),

        firstNameError$: firstNameError$,
        lastNameError$: lastNameError$,
        churchNameError$: churchNameError$,
        ministryError$: bioError$,
        websiteError$: websiteError$,
        parentChurchError$: parentChurchError$,
        cityError$: cityError$,
        churchStateError$: churchStateError$,
        churchError$: churchError$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        },
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
            userEntity: user,
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
      int saveType,
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
      String churchName,
      int ministryType,
      String churchDenomination,
      List<dynamic> locationData,
      String churchWebsite,
      String churchParent,
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

    if(ministryType != null){
      data['type'] = ministryType;
    }

    if(churchDenomination != null){
      data['churchDenomination'] = churchDenomination;
    }

    if(locationData != null){
      data['churchAddress'] = locationData[0];
      data['churchLat'] = locationData[1];
      data['churchLong'] = locationData[2];
    }

    if(churchWebsite != null){
      data['churchWebsite'] = churchWebsite;
    }

    if(churchParent != null){
      data['parentChurch'] = churchParent;
    }

    if(church != null && church.uid.substring(0, 7).toUpperCase() == churchId){
      data['churchInfo'] = {
        'churchName': church.churchName,
        'churchAddress': church.churchAddress,
        'churchDenomination': church.churchDenomination
      };
    } else if(unknownChurch != null) {
      data['churchInfo'] = {
        'churchName': unknownChurch,
        'churchAddress': null,
        'churchDenomination': null
      };
    } else if(noChurch == true){
      data['churchInfo'] = null;
    }

    if(isPublic != null && isPublic){
      data['isPublic'] = isPublic;
      data['status'] = 0;
    }

    LoginState state = userBloc.loginState$.value;
    if(state is LoggedInUser){

      if(saveType == 0 || saveType == 3){
        data['isProfileUpdated'] = true;
      }

      if(saveType == 1 || saveType == 4){
        data['isChurchUpdated'] = true;
      }

      await userRepository.updateUserData(state.uid, data);
    }

    yield SettingsMessageSuccess();
  }
}