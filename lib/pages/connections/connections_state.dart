import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class ConnectionsMessage {
  const ConnectionsMessage();
}

///
/// Error
///
class ConnectionsNotLoggedInError {
  const ConnectionsNotLoggedInError();
}

///
/// State
///
@immutable
class ConnectionsState extends Equatable {
  final bool isLoading;
  final Object error;
  final List<ConnectionItem> connectionItems;

  const ConnectionsState({
    @required this.isLoading,
    @required this.error,
    @required this.connectionItems,
  });

  ConnectionsState copyWith({isLoading, error, connectionItems}) {
    return ConnectionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      connectionItems: connectionItems ?? this.connectionItems,
    );
  }

  @override
  List get props => [
    isLoading,
    error,
    connectionItems
  ];

  @override
  bool get stringify => true;
}

@immutable
class ConnectionItem extends Equatable {
  final String id;
  final String uid;
  final String photo;
  final bool isChurch;
  final String fullName;
  final String churchName;
  final String aboutMe;

  const ConnectionItem({
    @required this.id,
    @required this.uid,
    @required this.photo,
    @required this.isChurch,
    @required this.fullName,
    @required this.churchName,
    @required this.aboutMe
  });

  @override
  List get props => [
    id,
    uid,
    photo,
    isChurch,
    fullName,
    churchName,
    aboutMe
  ];

  @override
  bool get stringify => true;
}