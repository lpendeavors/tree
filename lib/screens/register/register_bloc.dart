import 'dart:async';
import 'dart:io';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../screens/register/register_state.dart';
import '../../util/validation_utils.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

///
/// BLoC handle registering new account
///
class RegisterBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() submitRegister;
  final void Function(String) fullNameChanged;
  final void Function(String) emailChanged;
  final void Function(String) passwordChanged;

  ///
  /// Output streams
  ///
  final ValueStream<bool> isLoading$;
  final Stream<FullNameError> fullNameError$;
  final Stream<EmailError> emailError$;
  final Stream<PasswordError> passwordError$;
  final Stream<RegisterMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  RegisterBloc._({
    @required this.fullNameChanged,
    @required this.submitRegister,
    @required this.emailChanged,
    @required this.passwordChanged,
    @required this.isLoading$,
    @required this.emailError$,
    @required this.passwordError$,
    @required this.message$,
    @required this.fullNameError$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory RegisterBloc(FirebaseUserRepository userRepository) {
    ///
    /// Assert
    ///
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final fullNameSubject = BehaviorSubject<String>.seeded('');
    final emailSubject = BehaviorSubject<String>.seeded('');
    final passwordSubject = BehaviorSubject<String>.seeded('');
    final submitRegisterSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final fullNameError$ = fullNameSubject.map((fullName) {
      if (isValidFullName(fullName)) return null;
      return const FullNameMustBeAtLeast3Characters();
    });

    final emailError$ = emailSubject.map((email) {
      if (isValidEmail(email)) return null;
      return const InvalidEmailAddress();
    });

    final passwordError$ = passwordSubject.map((password) {
      if (isValidPassword(password)) return null;
      return const PasswordMustBeAtLeast6Characters();
    });

    final allFieldsAreValid$ = Rx.combineLatest(
    [
      fullNameError$,
      emailError$,
      passwordError$
    ],
    (allErrors) => allErrors.every((error) {
      print(error);
      return error == null;
    }));

    final message$ = submitRegisterSubject
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => performRegister(
          userRepository,
          fullNameSubject.value,
          emailSubject.value,
          passwordSubject.value,
          isLoadingSubject,
        ),
      ).publish();

    final subscriptions = <StreamSubscription>[
      message$.connect(),
    ];

    final controllers = <StreamController>[
      fullNameSubject,
      emailSubject,
      passwordSubject,
      submitRegisterSubject,
      isLoadingSubject,
    ];

    return RegisterBloc._(
      fullNameChanged: fullNameSubject.add,
      submitRegister: () => submitRegisterSubject.add(null),
      emailChanged: emailSubject.add,
      passwordChanged: passwordSubject.add,
      isLoading$: isLoadingSubject,
      fullNameError$: fullNameError$,
      emailError$: emailError$,
      passwordError$: passwordError$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
    );
  }

  static Stream<RegisterMessage> performRegister(
    FirebaseUserRepository userRepository,
    String fullName,
    String email,
    String password,
    Sink<bool> isLoadingSink,
  ) async* {
    print('[DEBUG] performRegister');
    try {
      isLoadingSink.add(true);
      await userRepository.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );
      yield const RegisterMessageSuccess();
    } catch (e) {
      yield _getRegisterError(e);
    } finally {
      isLoadingSink.add(false);
    }
  }

  static RegisterMessageError _getRegisterError(error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'ERROR_WEAK_PASSWORD':
          return const RegisterMessageError(WeakPasswordError());
        case 'ERROR_INVALID_EMAIL':
          return const RegisterMessageError(InvalidEmailError());
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          return const RegisterMessageError(EmailAlreadyInUserError());
        case 'ERROR_WRONG_PASSWORD':
          return const RegisterMessageError(WrongPasswordError());
        case 'ERROR_USER_DISABLED':
          return const RegisterMessageError(UserDisabledError());
        case 'ERROR_USER_NOT_FOUND':
          return const RegisterMessageError(UserNotFoundError());
        case 'ERROR_NETWORK_REQUEST_FAILED':
          return const RegisterMessageError(NetworkError());
        case 'ERROR_TOO_MANY_REQUESTS':
          return const RegisterMessageError(TooManyRequestsError());
        case 'ERROR_OOPERATION_NOT_ALLOWED':
          return const RegisterMessageError(OperationNotAllowedError());
      }
    }
    return RegisterMessageError(UnknownError(error));
  }
}