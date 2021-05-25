import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// TagConnectionsMessage
///
@immutable
abstract class TagConnectionsMessage {}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class TagConnectionsState extends Equatable {
  final List<ConnectionItem> connections;
  final bool isLoading;
  final Object error;

  const TagConnectionsState({
    @required this.connections,
    @required this.isLoading,
    @required this.error,
  });

  TagConnectionsState copyWith({connections, isLoading, error}) {
    return TagConnectionsState(
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        connections,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}

@immutable
class ConnectionItem extends Equatable {
  final String id;
  final String image;
  final String name;
  final String about;

  const ConnectionItem({
    @required this.id,
    @required this.image,
    @required this.name,
    @required this.about,
  });

  @override
  List get props => [
        id,
        image,
        name,
        about,
      ];

  @override
  bool get stringify => true;
}
