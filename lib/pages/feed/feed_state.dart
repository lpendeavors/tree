import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
@immutable
abstract class FeedMessage {}

class FeedItemAddedMessage implements FeedMessage {
  const FeedItemAddedMessage();
}

class FeedItemAddedMessageSuccess implements FeedItemAddedMessage {
  final FeedItem addedFeedItem;
  const FeedItemAddedMessageSuccess(this.addedFeedItem);
}

class FeetItemAddedMessageError implements FeedItemAddedMessage {
  final Object error;
  const FeetItemAddedMessageError(this.error);
}

///
/// Error
///
@immutable
abstract class FeedError {}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class FeedListState extends Equatable {
  final List<FeedItem> feedItems;
  final bool isLoading;
  final Object error;

  const FeedListState({
    @required this.feedItems,
    @required this.isLoading,
    @required this.error,
  });

  FeedListState copyWith({feedItems, isLoading, error}) {
    return FeedListState(
      feedItems: feedItems ?? this.feedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [feedItems, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class FeedItem extends Equatable {
  final String id;
  final List<String> tags;
  final int type;
  final DateTime timePosted;
  final String message;
  final String name;

  const FeedItem({
    @required this.id,
    @required this.tags,
    @required this.type,
    @required this.timePosted,
    @required this.message,
    @required this.name,
  });

  @override
  List get props => [id, tags, type, timePosted, message, name];

  @override
  bool get stringify => true;
}