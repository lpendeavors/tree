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
  const CommentAddedError();
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
  final bool isLoading;
  final Object error;

  const CommentsState({
    @required this.comments,
    @required this.isLoading,
    @required this.error,
  });

  CommentsState copyWith({comments, isLoading, error}) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [comments, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class CommentItem extends Equatable {
  final String id;
  final String fullName;
  final String message;
  final String image;
  final DateTime datePosted;
  final bool isGif;
  final String gif;
  final String owner;

  const CommentItem({
    @required this.id,
    @required this.fullName,
    @required this.message,
    @required this.image,
    @required this.datePosted,
    @required this.isGif,
    @required this.gif,
    @required this.owner,
  });

  @override
  List get props => [
    id,
    fullName,
    message,
    image,
    datePosted,
    isGif,
    gif,
    owner,
  ];

  @override
  bool get stringify => true;
}
