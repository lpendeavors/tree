import 'dart:async';

import '../../pages/login/login_state.dart';
import '../../util/validation_utils.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

///
/// BLoC
///
class PhoneLoginBloc implements BaseBloc {
  ///
  /// Input Functions
  ///
  final void Function() submitLogin;
  final void Function(String) countryCodeChanged;
  final void Function(String) phoneNumberChanged;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<LoginMessage> message$;
  final Stream<PhoneError> phoneError;

  ///
  /// Clean up
  ///
  @override
  final void Function() _dispose;

  PhoneLoginBloc._({
    @required this.phoneNumberChanged,
    @required this.countryCodeChanged,
    @required this.submitLogin,
    @required this.isLoading$,
    @required this.message$,
    @required this.phoneError,
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
    final submitLoginController = PublishSubject<void>();
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

    final message$ = submitLoginController
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

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      message$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingController,
      phoneController,
      submitLoginController
    ];

    ///
    /// Return BLoc
    ///
    return PhoneLoginBloc._(
      phoneNumberChanged: phoneController.add,
      countryCodeChanged: countryCodeController.add,
      submitLogin: () => submitLoginController.add(null),
      isLoading$: isLoadingController.stream,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      phoneError: phoneError$,
    );
  }

  static Stream<LoginMessage> sendVerificationCode(
    String countryCode,
    String phone,
    FirestoreUserRepository userRepository,
    Sink<bool> isLoadingController,
  ) async* {
    print('[DEBUG] send verification code');
    try {
      isLoadingController.add(true);
      Tuple2<String,bool> verification = await userRepository
          .phoneSignIn("$countryCode$phone");
      print(verification);
      if (verification.item2) {
        yield const LoginMessageSuccess();
      } else {
        yield LoginPhoneSuccess(verification.item1);
      }
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