import 'package:meta/meta.dart';

///
/// Login Message
///
@immutable
abstract class LoginMessage {}

class LoginMessageSuccess implements LoginMessage {
  const LoginMessageSuccess();
}

class LoginPhoneSuccess implements LoginMessage {
  final String verificationId;
  const LoginPhoneSuccess(this.verificationId);
}

class LoginMessageError implements LoginMessage {
  final LoginError error;
  const LoginMessageError(this.error);
}

///
/// Login error response
///
@immutable
abstract class LoginError {}

class NetworkError implements LoginError {
  const NetworkError();
}

class TooManyRequestsError implements LoginError {
  const TooManyRequestsError();
}

class UserNotFoundError implements LoginError {
  const UserNotFoundError();
}

class WrongPasswordError implements LoginError {
  const WrongPasswordError();
}

class InvalidEmailError implements LoginError {
  const InvalidEmailError();
}

class EmailAlreadyUsedError implements LoginError {
  const EmailAlreadyUsedError();
}

class WeakPasswordError implements LoginError {
  const WeakPasswordError();
}

///

class UnknownLoginError implements LoginError {
  final Object error;

  const UnknownLoginError(this.error);

  @override
  String toString() => 'UnknownLoginError{error: $error}';
}

///
/// Email edit text error and password edit text error
///
@immutable
abstract class EmailError {}

@immutable
abstract class PasswordError {}

class PasswordAtLeastSixCharacters implements PasswordError {
  const PasswordAtLeastSixCharacters();
}

class InvalidEmailAddress implements EmailError {
  const InvalidEmailAddress();
}

@immutable
abstract class PhoneError {}

@immutable
abstract class VerificationError {}

class PhoneNumberTenDigits implements PhoneError {
  const PhoneNumberTenDigits();
}

class VerificationInvalid implements VerificationError {
  const VerificationInvalid();
}
