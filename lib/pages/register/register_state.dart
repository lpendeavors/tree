import 'package:meta/meta.dart';

///
/// Login message
///
@immutable
abstract class RegisterMessage {}

class RegisterMessageSuccess implements RegisterMessage {
  const RegisterMessageSuccess();
}

class RegisterPhoneSuccess implements RegisterMessage {
  final String verificationId;
  const RegisterPhoneSuccess(this.verificationId);
}

class RegisterMessageComplete implements RegisterMessage {
  const RegisterMessageComplete();
}

class RegisterMessageError implements RegisterMessage {
  final RegisterError error;
  const RegisterMessageError(this.error);
}

///
/// Login error response
///
@immutable
abstract class RegisterError {}

class NetworkError implements RegisterError {
  const NetworkError();
}

class OperationNotAllowedError implements RegisterError {
  const OperationNotAllowedError();
}

class UserDisabledError implements RegisterError {
  const UserDisabledError();
}

class TooManyRequestsError implements RegisterError {
  const TooManyRequestsError();
}

class UserNotFoundError implements RegisterError {
  const UserNotFoundError();
}

class WrongPasswordError implements RegisterError {
  const WrongPasswordError();
}

class InvalidEmailError implements RegisterError {
  const InvalidEmailError();
}

class InvalidBusinessEmailError implements RegisterError {
  const InvalidBusinessEmailError();
}

class EmailAlreadyInUserError implements RegisterError {
  const EmailAlreadyInUserError();
}

class WeakPasswordError implements RegisterError {
  const WeakPasswordError();
}

class UnknownRegisterError implements RegisterError {
  final Object error;

  const UnknownRegisterError(this.error);

  @override
  String toString() => 'UnknownRegisterError{error: $error}';
}

class PhoneInUseError implements RegisterError {
  const PhoneInUseError();
}

///
/// Email edit text error and password edit text error
///
@immutable
abstract class EmailError {}

@immutable
abstract class PasswordError {}

@immutable
abstract class FirstNameError {}

@immutable
abstract class LastNameError {}

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

class PasswordMustBeAtLeast6Characters implements PasswordError {
  const PasswordMustBeAtLeast6Characters();
}

class PasswordsMustMatch implements PasswordError {
  const PasswordsMustMatch();
}

class InvalidEmailAddress implements EmailError {
  const InvalidEmailAddress();
}

class FirstNameMustBeAtLeast2Characters implements FirstNameError {
  const FirstNameMustBeAtLeast2Characters();
}

class LastNameMustBeAtLeast2Characters implements LastNameError {
  const LastNameMustBeAtLeast2Characters();
}