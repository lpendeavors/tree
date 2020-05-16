import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Enums
/// 
enum PostType { feed, quiz, poll, group, ad, user }

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
  final String timePosted;
  final String message;
  final String name;
  final String userImage;
  final bool isPoll;
  final List<String> postImages;

  const FeedItem({
    @required this.id,
    @required this.tags,
    @required this.timePosted,
    @required this.message,
    @required this.name,
    @required this.userImage,
    @required this.isPoll,
    @required this.postImages,
  });

  @override
  List get props => [
    id, 
    tags, 
    timePosted, 
    message, 
    name, 
    userImage, 
    isPoll,
    postImages,
  ];

  @override
  bool get stringify => true;
}