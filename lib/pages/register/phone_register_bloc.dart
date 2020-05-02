import 'dart:async';
import 'dart:io';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../pages/register/register_state.dart';
import '../../util/validation_utils.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

///
/// BLoC handle registering new account
///
class PhoneRegisterBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() submitRegister;
  final void Function(String) countryCodeChanged;
  final void Function(String) phoneNumberChanged;
  final void Function(AuthResult) verificationResultChanged;
  final void Function() submitUser;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<RegisterMessage> message$;
  final Stream<PhoneError> phoneError;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  PhoneRegisterBloc._({
    @required this.phoneNumberChanged,
    @required this.countryCodeChanged,
    @required this.verificationResultChanged,
    @required this.isLoading$,
    @required this.submitRegister,
    @required this.submitUser,
    @required this.message$,
    @required this.phoneError,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory PhoneRegisterBloc(FirestoreUserRepository userRepository) {
    ///
    /// Assert
    ///
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final countryCodeController = BehaviorSubject<String>.seeded('+1');
    final phoneController = BehaviorSubject<String>.seeded('');
    final verificationResultController = BehaviorSubject<AuthResult>.seeded(null);
    final submitRegisterController = PublishSubject<void>();
    final submitUserController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final phoneError$ = phoneController.map((phone) {
      if (isPhoneNumberValid(phone)) return null;
      return const PhoneNumberTenDigits();
    });

    final allFieldsAreValid$ = Rx.combineLatest(
    [
      phoneError$,
    ],
    (allErrors) => allErrors.every((error) {
      print(error);
      return error == null;
    }));

    final message$ = submitRegisterController
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => sendVerificationCode(
          countryCodeController.value,
          phoneController.value,
          userRepository,
          isLoadingController,
        ),
      ).publish();

    final subscriptions = <StreamSubscription>[
      message$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingController,
      phoneController,
      submitRegisterController,
      submitUserController,
      verificationResultController
    ];

    return PhoneRegisterBloc._(
      phoneNumberChanged: phoneController.add,
      verificationResultChanged: verificationResultController.add,
      countryCodeChanged: countryCodeController.add,
      submitRegister: () => submitRegisterController.add(null),
      submitUser: (){
        saveUserToDatabase(userRepository, verificationResultController.value);
      },
      isLoading$: isLoadingController.stream,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      phoneError: phoneError$,
    );
  }

  static void saveUserToDatabase(
      FirestoreUserRepository userRepository,
      AuthResult authResult
  ){
    if(authResult != null){
      userRepository.registerWithPhone(uid: authResult.user.uid, phone: authResult.user.phoneNumber);
    }
  }

  static Stream<RegisterMessage> sendVerificationCode(
    String countryCode,
    String phone,
    FirestoreUserRepository userRepository,
    Sink<bool> isLoadingSink
  ) async* {
    print('[DEBUG] send verification code');
    try {
      isLoadingSink.add(true);
      Tuple2<String,bool> verification = await userRepository.phoneSignIn("$countryCode$phone");
      if (verification.item2) {
        yield const RegisterMessageSuccess();
      } else {
        yield RegisterPhoneSuccess(verification.item1);
      }
    } catch (e) {
      yield _getRegisterError(e);
    } finally {
      isLoadingSink.add(false);
    }
  }

  static RegisterMessageError _getRegisterError(error) {
    if (error is PlatformException) {
      switch (error.code) {

      }
    }
    return RegisterMessageError(UnknownRegisterError(error));
  }
}