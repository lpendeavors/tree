import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../models/old/user_chat_data.dart';

@immutable
abstract class LoginState {
  const LoginState();
}

class LoggedInUser extends Equatable implements LoginState {
  final String uid;
  final String email;
  final String fullName;
  final bool isAdmin;
  final List<ChatData> chatList;

  const LoggedInUser({
    @required this.uid,
    @required this.email,
    @required this.fullName,
    @required this.isAdmin,
    @required this.chatList,
  });

  @override
  List get props {
    return [uid, email, fullName, chatList];
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