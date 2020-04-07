import 'dart:async';

import '../../screens/login/login_state.dart';
import '../../util/validation_utils.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// BLoC
///
class PhoneLoginBloc implements BaseBloc {
  ///
  /// Input Functions
  ///
  final void Function() submitLogin;
  final void Function() sendVerification;
  final void Function(String) countryCodeChanged;
  final void Function(String) phoneNumberChanged;
  final void Function(String) verificationCodeChanged;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<LoginMessage> verificationMessage$;
  final Stream<PhoneError> phoneError;
  final Stream<VerificationError> verificationError;

  ///
  /// Clean up
  ///
  @override
  final void Function() _dispose;

  PhoneLoginBloc._({
    @required this.phoneNumberChanged,
    @required this.verificationCodeChanged,
    @required this.countryCodeChanged,
    @required this.submitLogin,
    @required this.sendVerification,
    @required this.isLoading$,
    @required this.verificationMessage$,
    @required this.phoneError,
    @required this.verificationError,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory PhoneLoginBloc(FirestoreUserRepository userRepository) {
    ///
    /// Assert
    ///
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Controllers
    ///
    final countryCodeController = BehaviorSubject<String>.seeded('+1');
    final phoneController = BehaviorSubject<String>.seeded('');
    final verificationController = BehaviorSubject<String>.seeded('');
    final sendVerificationController = PublishSubject<void>();
    final submitLoginController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final  phoneError$ = phoneController.stream.map<PhoneError>((phone) {
      if (isPhoneNumberValid(phone)) return null;
      return const PhoneNumberTenDigits();
    });

    final verificationError$ = verificationController.stream.map<VerificationInvalid>((verification) {
      if (isValidVerificationCode(verification)) return null;
      return const VerificationInvalid();
    });

    final verificationMessage$ = sendVerificationController
      .withLatestFrom(phoneError$, (_, PhoneError error) => error)
      .where((error) => null)
      .withLatestFrom(phoneController, (_, phoneNumber) => phoneNumber)
      .switchMap((phone) => sendVerificationCode(
        phone,
        userRepository,
        isLoadingController,
      )).publish();

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      verificationMessage$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingController,
      phoneController,
      verificationController,
    ];

    ///
    /// Return BLoc
    ///
    return PhoneLoginBloc._(
      phoneNumberChanged: phoneController.add,
      verificationCodeChanged: verificationController.add,
      countryCodeChanged: countryCodeController.add,
      submitLogin: () => submitLoginController.add(null),
      sendVerification: () => sendVerificationController.add(null),
      isLoading$: isLoadingController.stream,
      verificationMessage$: verificationMessage$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      phoneError: phoneError$,
      verificationError: verificationError$,
    );
  }

  static Stream<LoginMessage> sendVerificationCode(
    String phone,
    FirestoreUserRepository userRepository,
    Sink<bool> isLoadingController,
  ) async* {
    print('[DEBUG] send verification code');
    try {
      isLoadingController.add(true);
      await userRepository.phoneSignIn(
        phone,
        Duration(seconds: 60),
        (phoneAuthCredential) async {
          print('[PHONE_LOGIN_BLOC] phoneAuthCredential=$phoneAuthCredential');
        },
        (authException) {},
        (s, [x]) {},
        null
      );
      yield null;
    } catch (e) {
      yield _getLoginError(e);
    } finally {
      isLoadingController.add(false);
    }
  }

  static LoginMessageError _getLoginError(error) {
    if (error is PlatformException) {
      switch (error.code) {

      }
    }
    return LoginMessageError(UnknownError(error));
  }
}