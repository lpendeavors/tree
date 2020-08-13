import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/poll_data.dart';

///
/// Enums
///
enum PostType { feed, quiz, poll, group, ad, user }
enum PostOption { edit, delete, unconnect, report }
enum ShareOption { withComment, withoutComment }

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

class FeedItemLikeMessage implements FeedMessage {
  const FeedItemLikeMessage();
}

class FeedItemLikeSuccess implements FeedItemLikeMessage {
  const FeedItemLikeSuccess();
}

class FeedItemLikeError implements FeedItemLikeMessage {
  final Object error;
  const FeedItemLikeError(this.error);
}

class FeedUnconnectMessage implements FeedMessage {
  const FeedUnconnectMessage();
}

class FeedUnconnectSuccess implements FeedUnconnectMessage {
  const FeedUnconnectSuccess();
}

class FeedUnconnectError implements FeedUnconnectMessage {
  final Object error;
  const FeedUnconnectError(this.error);
}

class FeedDeleteMessage implements FeedMessage {
  const FeedDeleteMessage();
}

class FeedDeleteSuccess implements FeedDeleteMessage {
  const FeedDeleteSuccess();
}

class FeedDeleteError implements FeedDeleteMessage {
  final Object error;
  const FeedDeleteError(this.error);
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
  final bool hasNotifications;
  final bool isLoading;
  final Object error;

  const FeedListState({
    @required this.feedItems,
    @required this.hasNotifications,
    @required this.isLoading,
    @required this.error,
  });

  FeedListState copyWith({feedItems, hasNotifications, isLoading, error}) {
    return FeedListState(
      feedItems: feedItems ?? this.feedItems,
      hasNotifications: hasNotifications ?? this.hasNotifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [feedItems, hasNotifications, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class FeedItem extends Equatable {
  final String id;
  final List<String> tags;
  final DateTime timePosted;
  final String timePostedString;
  final String message;
  final String name;
  final String userImage;
  final String userId;
  final bool isPoll;
  final List<String> postImages;
  final bool isMine;
  final bool isLiked;
  final String abbreviatedPost;
  final bool isShared;
  final List<PollData> pollData;

  const FeedItem({
    @required this.id,
    @required this.tags,
    @required this.timePosted,
    @required this.timePostedString,
    @required this.message,
    @required this.name,
    @required this.userImage,
    @required this.userId,
    @required this.isPoll,
    @required this.postImages,
    @required this.isMine,
    @required this.isLiked,
    @required this.abbreviatedPost,
    @required this.isShared,
    @required this.pollData,
  });

  @override
  List get props => [
        id,
        tags,
        timePosted,
        timePostedString,
        message,
        name,
        userImage,
        userId,
        isPoll,
        postImages,
        isMine,
        isLiked,
        abbreviatedPost,
        isShared,
        pollData,
      ];

  @override
  bool get stringify => true;
}
