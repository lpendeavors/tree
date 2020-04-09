import 'package:meta/meta.dart';

///
/// Verification Message
///
@immutable class VerificationMessage {}

class PhoneVerificationSuccess implements VerificationMessage {
  const PhoneVerificationSuccess();
}

class PhoneVerificationError implements VerificationMessage {
  final VerificationError error;
  const PhoneVerificationError(this.error);
}

///
/// Verification error response
///
@immutable
abstract class VerificationError {}

class WrongCodeError implements VerificationError {
  const WrongCodeError();
}

class UnknownError implements VerificationError {
  final Object error;

  const UnknownError(this.error);

  @override
  String toString() => 'UnknownError{error: $error}';
}

///
/// Verification code edit text error
///
@immutable
abstract class CodeError {}

@immutable
abstract class IdError {}

class VerificationCodeSixDigits implements CodeError {
  const VerificationCodeSixDigits();
}

class VerificationIdInvalid implements IdError {
  const VerificationIdInvalid();
}