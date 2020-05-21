import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pages/phone_verification/phone_verification_state.dart';
import '../../util/validation_utils.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';

///
/// BLoC
///
class PhoneVerificationBloc implements BaseBloc {
  ///
  /// Input Functions
  ///
  final void Function() submitLogin;
  final void Function(String) verficationCodeChanged;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<VerificationMessage> message$;
  final Stream<CodeError> codeError;

  ///
  /// Clean up
  ///
  @override
  final void Function() _dispose;

  PhoneVerificationBloc._({
    @required this.verficationCodeChanged,
    @required this.submitLogin,
    @required this.isLoading$,
    @required this.message$,
    @required this.codeError,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory PhoneVerificationBloc({
    @required FirestoreUserRepository userRepository,
    @required String verificationId,
  }) {
    ///
    /// Assert
    ///
    assert(userRepository != null, 'userRepository cannot be null');
    assert(verificationId != null, 'verificationId cannot be null');

    ///
    /// Controllers
    ///
    final verificationCodeController = BehaviorSubject<String>.seeded('');
    final submitLoginController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final codeError$ = verificationCodeController.map((code) {
      if (isValidVerificationCode(code)) return null;
      return const VerificationCodeSixDigits();
    });

    final allFieldsAreValid$ = Rx.combineLatest(
      [
        codeError$,
      ],
      (allErrors) => allErrors.every((error) {
        print(error);
        return error == null;
      }));

    final message$ = submitLoginController
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => sendConfirmationCode(
          verificationCodeController.value,
          verificationId,
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
      verificationCodeController,
      submitLoginController,
    ];

    ///
    /// Return BLoC
    ///
    return PhoneVerificationBloc._(
      verficationCodeChanged: verificationCodeController.add,
      submitLogin: () => submitLoginController.add(null),
      isLoading$: isLoadingController.stream,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      codeError: codeError$,
    );
  }

  static Stream<VerificationMessage> sendConfirmationCode(
    String code,
    String id,
    FirestoreUserRepository userRepository,
    Sink<bool> isLoadingController,
  ) async* {
    print('[PHONE_VERIFICATION_BLOC] send confirmation code id=$id, code=$code');
    try {
      isLoadingController.add(true);
      AuthResult result = await userRepository.verifyPhoneCode(
        code,
        id,
      );
      yield PhoneVerificationSuccess(result);
    } catch (e) {
      yield _getVerificationError(e);
    } finally {
      isLoadingController.add(false);
    }
  }

  static PhoneVerificationError _getVerificationError(error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'ERROR_INVALID_VERIFICATION_ID':

      }
    }
    return PhoneVerificationError(UnknownVerificationError(error));
  }
}