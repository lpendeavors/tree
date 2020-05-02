import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

///
/// Verification Message
///
@immutable
class VerificationMessage {}

class PhoneVerificationSuccess implements VerificationMessage {
  final AuthResult result;
  const PhoneVerificationSuccess(this.result);
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

class UnknownVerificationError implements VerificationError {
  final Object error;

  const UnknownVerificationError(this.error);

  @override
  String toString() => 'UnknownVerificationError{error: $error}';
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