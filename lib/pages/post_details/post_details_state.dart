import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../comments/comments_state.dart';
import '../feed/feed_state.dart';

/// 
/// Message
/// 
abstract class PostDetailsMessage {
  const PostDetailsMessage();
}

/// 
/// State
/// 
@immutable
class PostDetailsState extends Equatable {
  final FeedItem postDetails;
  final List<CommentItem> commentItems;
  final bool isLoading;
  final Object error;

  const PostDetailsState({
    @required this.postDetails,
    @required this.commentItems,
    @required this.isLoading,
    @required this.error,
  });

  PostDetailsState copyWith({postDetails, commentItems, isLoading, error}) {
    return PostDetailsState(
      postDetails: postDetails ?? this.postDetails,
      commentItems: commentItems ?? this.commentItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    postDetails,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}
