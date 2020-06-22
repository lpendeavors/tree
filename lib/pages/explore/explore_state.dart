import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// 
/// Enum
/// 
enum PostType { other, image, video }

///
/// Message
///
@immutable
abstract class ExploreMessage {}

class ConnectionAddedSuccess implements ExploreMessage {
  const ConnectionAddedSuccess();
}

class ConnectionAddedError implements ExploreMessage {
  final Object error;
  const ConnectionAddedError(this.error);
}

///
/// Error
///
@immutable
abstract class ExploreError {}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class ExploreState extends Equatable {
  final List<ConnectionItem> requestItems;
  final List<ConnectionItem> connectionItems;
  final List<PostItem> postItems;
  final bool isLoading;
  final Object error;

  const ExploreState({
    this.requestItems,
    this.connectionItems,
    this.postItems,
    this.isLoading,
    this.error,
  });

  ExploreState copyWith({requestItems, connectionItems, postItems, isLoading, error}) {
    return ExploreState(
      requestItems: requestItems ?? this.requestItems,
      connectionItems: connectionItems ?? this.connectionItems,
      postItems: postItems ?? this.postItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    requestItems,
    connectionItems, 
    postItems, 
    isLoading, 
    error
  ];

  @override
  bool get stringify => true;
}

@immutable
class ConnectionItem extends Equatable {
  final String id;
  final String name;
  final String church;
  final String city;
  final bool isChurch;
  final String image;
  final String denomination;

  const ConnectionItem({
    @required this.id,
    @required this.name,
    @required this.church,
    @required this.city,
    @required this.isChurch,
    @required this.image,
    @required this.denomination,
  });

  @override
  List get props => [
    id, 
    name, 
    church, 
    city,
    isChurch,
    image,
    denomination,
  ];

  @override
  bool get stringify => true;
}

@immutable
class PostItem extends Equatable {
  final String id;
  final String image;
  final int type;

  const PostItem({
    @required this.id,
    @required this.image,
    @required this.type,
  });

  @override
  List get props => [
    id, 
    image,
    type,
  ];

  @override
  bool get stringify => true;
}