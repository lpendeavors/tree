import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
@immutable
abstract class ExploreMessage {}

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
  final List<ConnectionItem> connectionItems;
  final List<PostItem> postItems;
  final bool isLoading;
  final Object error;

  const ExploreState({
    this.connectionItems,
    this.postItems,
    this.isLoading,
    this.error,
  });

  ExploreState copyWith({connectionItems, postItems, isLoading, error}) {
    return ExploreState(
      connectionItems: connectionItems ?? this.connectionItems,
      postItems: postItems ?? this.postItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [connectionItems, postItems, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class RequestItem extends Equatable {
  final String id;

  const RequestItem({
    @required this.id,
  });
  
  @override
  List get props => [
    id,
  ];

  @override
  bool get stringify => true;
}

@immutable
class SuggestionItem extends Equatable {
  final String id;

  const SuggestionItem({
    @required this.id,
  });

  @override
  List get props => [
    id,
  ];

  @override
  bool get stringify => true;
}

@immutable
class ConnectionItem extends Equatable {
  final String id;
  final String name;
  final String church;
  final String location;
  final bool isChurch;
  final String image;

  const ConnectionItem({
    @required this.id,
    @required this.name,
    @required this.church,
    @required this.location,
    @required this.isChurch,
    @required this.image,
  });

  @override
  List get props => [
    id, 
    name, 
    church, 
    location,
    isChurch,
    image,
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