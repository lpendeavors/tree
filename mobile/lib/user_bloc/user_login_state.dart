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
  final String image;
  final List<String> connections;
  final String church;
  final String city;
  final String token;
  final bool isChurch;
  final bool isVerified;
  final String churchId;
  final bool isYouth;
  final List<String> mutedChats;
  final bool isChurchUpdated;
  final bool isProfileUpdated;
  final List<String> receivedRequests;
  final List<String> sentRequests;
  final bool isSuspended;

  const LoggedInUser({
    @required this.uid,
    @required this.email,
    @required this.fullName,
    @required this.isAdmin,
    @required this.chatList,
    @required this.image,
    @required this.connections,
    @required this.church,
    @required this.city,
    @required this.token,
    @required this.isChurch,
    @required this.isVerified,
    @required this.churchId,
    @required this.isYouth,
    @required this.mutedChats,
    @required this.isChurchUpdated,
    @required this.isProfileUpdated,
    @required this.receivedRequests,
    @required this.sentRequests,
    @required this.isSuspended,
  });

  @override
  List get props {
    return [
      uid,
      email,
      fullName,
      chatList,
      image,
      connections,
      church,
      city,
      token,
      isChurch,
      isVerified,
      churchId,
      isYouth,
      mutedChats,
      isChurchUpdated,
      isProfileUpdated,
      receivedRequests,
      sentRequests,
      isSuspended,
    ];
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
