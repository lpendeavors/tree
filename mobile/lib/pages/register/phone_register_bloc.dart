import 'dart:async';

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
  final void Function(String) emailAddressChanged;
  final void Function(String) churchNameChanged;
  final void Function(String) firstNameChanged;
  final void Function(String) lastNameChanged;
  final void Function(String) passwordChanged;
  final void Function(String) confirmPasswordChanged;
  final void Function(UserCredential) verificationResultChanged;
  final void Function(bool) submitUser;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<RegisterMessage> message$;
  final Stream<RegisterMessage> saveResult$;
  final Stream<PhoneError> phoneError;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  PhoneRegisterBloc._({
    @required this.phoneNumberChanged,
    @required this.countryCodeChanged,
    @required this.emailAddressChanged,
    @required this.churchNameChanged,
    @required this.firstNameChanged,
    @required this.lastNameChanged,
    @required this.passwordChanged,
    @required this.confirmPasswordChanged,
    @required this.verificationResultChanged,
    @required this.isLoading$,
    @required this.submitRegister,
    @required this.submitUser,
    @required this.message$,
    @required this.saveResult$,
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
    final emailController = BehaviorSubject<String>.seeded('');
    final churchNameController = BehaviorSubject<String>.seeded('');
    final firstNameController = BehaviorSubject<String>.seeded('');
    final lastNameController = BehaviorSubject<String>.seeded('');
    final passwordController = BehaviorSubject<String>.seeded('');
    final confirmPasswordController = BehaviorSubject<String>.seeded('');
    final verificationResultController =
        BehaviorSubject<UserCredential>.seeded(null);
    final submitRegisterController = PublishSubject<void>();
    final submitUserController = BehaviorSubject<bool>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final phoneError$ = phoneController.map((phone) {
      if (isPhoneNumberValid(phone)) return null;
      return const PhoneNumberTenDigits();
    });

    final emailError$ = emailController.map((email) {
      if (isValidEmail(email)) return null;
      return const InvalidEmailAddress();
    });

    final churchNameError$ = churchNameController.map((name) {
      if (isValidName(name)) return null;
      return const ChurchNameMustBeAtLeast2Characters();
    });

    final firstNameError$ = firstNameController.map((name) {
      if (isValidName(name)) return null;
      return const FirstNameMustBeAtLeast2Characters();
    });

    final lastNameError$ = lastNameController.map((name) {
      if (isValidName(name)) return null;
      return const LastNameMustBeAtLeast2Characters();
    });

    final passwordError$ = passwordController.map((password) {
      if (isValidPassword(password)) return null;
      return const PasswordMustBeAtLeast6Characters();
    });

    final confirmPasswordError$ = Rx.combineLatest(
        [passwordController, confirmPasswordController], (values) {
      if (values[0] == values[1]) {
        return null;
      }
      return const PasswordsMustMatch();
    });

    final allFieldsAreValid$ = Rx.combineLatest(
        [
          phoneError$,
        ],
        (allErrors) => allErrors.every((error) {
              print(error);
              return error == null;
            }));

    final allInfoIsValid$ = Rx.combineLatest(
        [
          emailError$,
          churchNameError$,
          firstNameError$,
          lastNameError$,
          passwordError$,
          confirmPasswordError$
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
        )
        .publish();

    final saveResult$ = submitUserController
        .withLatestFrom(allInfoIsValid$, (isChurch, bool isValid) {
          print('$isChurch $isValid');
          return !isChurch || isValid;
        })
        .where((isValid) => isValid)
        .exhaustMap(
          (_) => saveUserToDatabase(
              userRepository,
              verificationResultController.value,
              emailController.value,
              churchNameController.value,
              firstNameController.value,
              lastNameController.value,
              passwordController.value,
              submitUserController.value),
        )
        .publish();

    final subscriptions = <StreamSubscription>[
      message$.connect(),
      saveResult$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingController,
      phoneController,
      emailController,
      churchNameController,
      firstNameController,
      lastNameController,
      passwordController,
      confirmPasswordController,
      submitRegisterController,
      submitUserController,
      verificationResultController
    ];

    return PhoneRegisterBloc._(
      phoneNumberChanged: phoneController.add,
      verificationResultChanged: verificationResultController.add,
      emailAddressChanged: emailController.add,
      churchNameChanged: churchNameController.add,
      firstNameChanged: firstNameController.add,
      lastNameChanged: lastNameController.add,
      passwordChanged: passwordController.add,
      confirmPasswordChanged: confirmPasswordController.add,
      countryCodeChanged: countryCodeController.add,
      submitRegister: () => submitRegisterController.add(null),
      submitUser: submitUserController.add,
      isLoading$: isLoadingController.stream,
      message$: message$,
      saveResult$: saveResult$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      phoneError: phoneError$,
    );
  }

  static Stream<RegisterMessage> saveUserToDatabase(
      FirestoreUserRepository userRepository,
      UserCredential authResult,
      String email,
      String churchName,
      String firstName,
      String lastName,
      String password,
      bool isChurch) async* {
    try {
      if (authResult != null) {
        if (isChurch &&
            (email.contains("aol") ||
                email.contains("gmail") ||
                email.contains("yahoo") ||
                email.contains("hotmail"))) {
          print(
              '$isChurch ${(email.contains("aol") || email.contains("gmail") || email.contains("yahoo") || email.contains("hotmail"))}');
          yield RegisterMessageError(InvalidBusinessEmailError());
          return;
        }

        await userRepository.registerWithPhone(
          user: authResult.user,
          email: email,
          churchName: churchName,
          firstName: firstName,
          lastName: lastName,
          password: password,
        );
        yield const RegisterMessageComplete();
      }
    } catch (e) {
      yield _getRegisterError(e);
    }
  }

  static Stream<RegisterMessage> sendVerificationCode(
    String countryCode,
    String phone,
    FirestoreUserRepository userRepository,
    Sink<bool> isLoadingSink,
  ) async* {
    print('[DEBUG] send verification code');
    try {
      isLoadingSink.add(true);
      Tuple2<String, bool> verification =
          await userRepository.phoneRegister("$countryCode$phone");
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
    print(error);
    if (error is PlatformException) {
      switch (error.code) {
      }
    }
    if (error == "already_in_use") {
      return RegisterMessageError(PhoneInUseError());
    }
    return RegisterMessageError(UnknownRegisterError(error));
  }
}
