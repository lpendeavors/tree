import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

///
/// Enums
///
enum MessageType { group, conversation, edit }

///
/// MessageCreateMessage
///
@immutable
abstract class MessageCreateMessage {}

class MessageCreateSuccess implements MessageCreateMessage {
  final Map<String, dynamic> details;
  const MessageCreateSuccess(this.details);
}

class MessageCreateError implements MessageCreateMessage {
  final Object error;
  const MessageCreateError(this.error);
}

class NotLoggedInError {
  const NotLoggedInError();
}

class MembersError {
  const MembersError();
}

@immutable
class CreateMessageState extends Equatable {
  final List<ConnectionItem> myConnections;
  final bool isLoading;
  final Object error;

  const CreateMessageState({
    @required this.myConnections,
    @required this.isLoading,
    @required this.error,
  });

  CreateMessageState copyWith({myConnections, isLoading, error}) {
    return CreateMessageState(
      myConnections: myConnections ?? this.myConnections,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        myConnections,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}

@immutable
class MemberItem extends Equatable {
  final String id;
  final String image;
  final String name;
  final bool groupAdmin;
  final String token;

  const MemberItem({
    @required this.id,
    @required this.image,
    @required this.name,
    @required this.groupAdmin,
    @required this.token,
  });

  @override
  List get props => [
        id,
        image,
        name,
        groupAdmin,
        token,
      ];

  @override
  bool get stringify => true;
}

@immutable
class ConnectionItem extends Equatable {
  final String id;
  final String name;
  final String about;
  final String image;
  final String token;

  const ConnectionItem({
    @required this.id,
    @required this.name,
    @required this.about,
    @required this.image,
    @required this.token,
  });

  @override
  List get props => [
        id,
        name,
        about,
        image,
        token,
      ];

  @override
  bool get stringify => true;
}
