import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../screens/forgot_password/forgot_password_state.dart';
import '../../util/validation_utils.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class ForgotPasswordBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() submit;
  final void Function(String) emailChanged;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<ForgotPasswordMessage> message$;
  final Stream<EmailError> emailError$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ForgotPasswordBloc._(
      this._dispose, {
      @required this.isLoading$,
      @required this.message$,
      @required this.emailError$,
      @required this.submit,
      @required this.emailChanged,
  });

  @override
  void dispose() => _dispose();

  factory ForgotPasswordBloc(final FirestoreUserRepository userRepository) {
    assert(userRepository != null, 'userRepository must not be null');

    final isLoadingSubject = BehaviorSubject.seeded(false);
    final emailSubject = BehaviorSubject.seeded('');
    final submitSubject = PublishSubject();

    final emailError$ = emailSubject.map<EmailError>((email) {
      if (isValidEmail(email)) {
        return null;
      }
      return const InvalidEmailAddress();
    });

    final valid$ = submitSubject
      .withLatestFrom(
        emailSubject,
        (_, String email) => isValidEmail(email),
      ).share();

    final message$ = Rx.merge([
      valid$
        .doOnData((valid) => print("valid1=$valid"))
        .where((valid) => !valid)
        .map((_) => const InvalidInformation()),
      valid$
        .doOnData((valid) => print("valid2=$valid"))
        .where((valid) => valid)
        .withLatestFrom(
          emailSubject,
          (_, String email) => email,
      )
      .doOnData((email) => print('email=$email'))
      .doOnEach((error) => print('error=$error'))
      .exhaustMap(
          (email) => performSendEmail(
            email, userRepository, isLoadingSubject,
          ),
      ),
    ]).publish();

    final subscriptions = [
      emailSubject.listen((email) => print('[FORGOT_PASSWORD_BLOC] email=$email')),
      emailError$.listen((emailError) => print('[FORGOT_PASSWORD_BLOC] emailError=$emailError')),
      message$.listen((message) => print('[FORGOT_PASSWORD_BLOC] message=$message')),
      message$.connect()
    ];

    final controllers = <StreamController>[
      isLoadingSubject, submitSubject, emailSubject
    ];

    return ForgotPasswordBloc._(
      () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
        print('[FORGOT_PASSWORD_BLOC] disposed');
      },
      isLoading$: isLoadingSubject.stream,
      message$: message$,
      emailError$: emailError$,
      submit: () => submitSubject.add(null),
      emailChanged: emailSubject.add,
    );
  }

  static Stream<ForgotPasswordMessage> performSendEmail(
    String email,
      FirestoreUserRepository userRepository,
      Sink<bool> isLoadingSink,
  ) async* {
    print('[FORGOT_PASSWORD_BLOC] performSendEmail');
    isLoadingSink.add(true);

    try {
      await userRepository.sendPasswordResetEmail(email);
      yield const SendPasswordResetEmailSuccess();
    } catch (e) {
      if (e is PlatformException) {
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
            yield const SendPasswordResetEmailFailure(InvalidEmailError());
            break;
          case 'ERROR_USER_NOT_FOUND':
            yield const SendPasswordResetEmailFailure(UserNotFoundError());
            break;
        }
      } else {
        yield SendPasswordResetEmailFailure(UnknownError());
      }
    } finally {
      isLoadingSink.add(false);
    }
  }
}