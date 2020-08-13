import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class CommentsMessage {
  const CommentsMessage();
}

abstract class CommentAddedMessage implements CommentsMessage {
  const CommentAddedMessage();
}

class CommentAddedSuccess implements CommentAddedMessage {
  const CommentAddedSuccess();
}

class CommentAddedError implements CommentAddedMessage {
  final Object error;
  const CommentAddedError(this.error);
}

abstract class CommentLikeMessage {
  const CommentLikeMessage();
}

class CommentLikeSuccess implements CommentLikeMessage {
  const CommentLikeSuccess();
}

class CommentLikeError implements CommentLikeMessage {
  final Object error;
  const CommentLikeError(this.error);
}

class CommentEmptyError {
  const CommentEmptyError();
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class CommentsState extends Equatable {
  final List<CommentItem> comments;
  final PostItem postDetails;
  final bool isLoading;
  final Object error;

  const CommentsState({
    @required this.comments,
    @required this.postDetails,
    @required this.isLoading,
    @required this.error,
  });

  CommentsState copyWith({comments, postDetails, isLoading, error}) {
    return CommentsState(
      comments: comments ?? this.comments,
      postDetails: postDetails ?? this.postDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [comments, postDetails, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class CommentItem extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String message;
  final String image;
  final DateTime datePosted;
  final bool isGif;
  final String gif;
  final String owner;
  final List<CommentItem> replies;
  final List<String> likes;
  final bool isMine;
  final bool isLiked;

  const CommentItem({
    @required this.id,
    @required this.userId,
    @required this.fullName,
    @required this.message,
    @required this.image,
    @required this.datePosted,
    @required this.isGif,
    @required this.gif,
    @required this.owner,
    @required this.replies,
    @required this.likes,
    @required this.isMine,
    @required this.isLiked,
  });

  @override
  List get props => [
        id,
        userId,
        fullName,
        message,
        image,
        datePosted,
        isGif,
        gif,
        owner,
        replies,
        isMine,
        likes,
        isLiked,
      ];

  @override
  bool get stringify => true;
}

@immutable
class PostItem extends Equatable {
  final bool isMuted;
  final String id;

  const PostItem({
    @required this.isMuted,
    @required this.id,
  });

  @override
  List get props => [isMuted, id];

  @override
  bool get stringify => true;
}
