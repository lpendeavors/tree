import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Enum
///
enum PostMediaType { image, video }

///
/// EditPostMessage
///
@immutable
abstract class EditPostMessage {}

@immutable
abstract class PostAddedMessage implements EditPostMessage {
  const PostAddedMessage();
}

class PostAddedMessageSuccess implements PostAddedMessage {
  const PostAddedMessageSuccess();
}

class PostAddedMessageError implements PostAddedMessage {
  final Object error;
  PostAddedMessageError(this.error);
}

@immutable
abstract class PostError {}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class EditPostState extends Equatable {
  final FeedPostItem postItem;
  final bool isLoading;
  final Object error;

  const EditPostState({
    @required this.postItem,
    @required this.isLoading,
    @required this.error,
  });

  EditPostState copyWith({postItem, isLoading, error}) {
    return EditPostState(
      postItem: postItem ?? this.postItem,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        postItem,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}

@immutable
class FeedPostItem extends Equatable {
  final String id;
  final bool isPublic;
  final bool connectionsOnly;
  final String message;
  final List<String> images;
  final List<String> videos;
  final List<String> tagged;

  const FeedPostItem({
    @required this.id,
    @required this.isPublic,
    @required this.connectionsOnly,
    @required this.message,
    @required this.images,
    @required this.videos,
    @required this.tagged,
  });

  @override
  List get props => [
        id,
        isPublic,
        connectionsOnly,
        message,
        images,
        videos,
        tagged,
      ];

  @override
  bool get stringify => true;
}

@immutable
class TaggedItem extends Equatable {
  final String id;
  final String name;
  final String image;

  const TaggedItem({
    @required this.id,
    @required this.name,
    @required this.image,
  });

  @override
  List get props => [
        id,
        name,
        image,
      ];

  @override
  bool get stringify => true;
}
