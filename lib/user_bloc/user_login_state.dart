import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class LoginState {
  const LoginState();
}

class LoggedInUser extends Equatable implements LoginState {
  final String uid;
  final String email;
  final String fullName;
  final bool isAdmin;

  const LoggedInUser({
    @required this.uid,
    @required this.email,
    @required this.fullName,
    @required this.isAdmin,
  });

  @override
  List get props {
    return [uid, email, fullName, isAdmin];
  }

  @override
  bool get stringify => true;
}

class Unauthenticated implements LoginState {
  const Unauthenticated();
}

///
/// Message exposed from UserBloc
///
@immutable
abstract class UserMessage {}

class UserLogoutMessage implements UserMessage {}

class UserLogoutMessageSuccess implements UserLogoutMessage {
  const UserLogoutMessageSuccess();
}

class UserLogoutMessageError implements UserLogoutMessage {
  final Object error;
  const UserLogoutMessageError(this.error);
}