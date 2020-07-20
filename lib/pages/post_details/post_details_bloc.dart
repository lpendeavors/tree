import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../util/post_utils.dart';
import '../comments/comments_state.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../data/comment/firestore_comment_repository.dart';
import '../../models/old/post_entity.dart';
import '../../models/old/comment_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../feed/feed_state.dart';
import './post_details_state.dart';

const _kInitialPostDetailsState = PostDetailsState(
  postDetails: null,
  commentItems: null,
  isLoading: true,
  error: null,
);

class PostDetailsBloc extends BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final ValueStream<PostDetailsState> postDetailsState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  PostDetailsBloc._({
    @required this.postDetailsState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory PostDetailsBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
    @required FirestoreCommentRepository commentRepository,
    @required String postId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(commentRepository != null, 'commentRepository cannot be null');
    assert(postId != null, 'postId cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final postDetailsState$ = _getPostDetails(
      userBloc,
      postRepository,
      commentRepository,
      postId,
    ).publishValueSeeded(_kInitialPostDetailsState);

    final subscriptions = <StreamSubscription>[
      postDetailsState$.connect(),
    ];

    return PostDetailsBloc._(
        postDetailsState$: postDetailsState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<PostDetailsState> _toState(
    LoginState loginState,
    FirestorePostRepository postRepository,
    FirestoreCommentRepository commentRepository,
    String postId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialPostDetailsState.copyWith(
          error: 'NotLoggedInError',
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(
        postRepository.postById(postId: postId),
        commentRepository.getByPost(postId),
        (post, comments) {
          return _kInitialPostDetailsState.copyWith(
            postDetails: _entityToPostItem(post, loginState.uid),
            commentItems: _entitiesToCommentItems(comments, loginState.uid),
            isLoading: false,
          );
        },
      ).startWith(_kInitialPostDetailsState).onErrorReturnWith((e) {
        return _kInitialPostDetailsState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialPostDetailsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static FeedItem _entityToPostItem(
    PostEntity entity,
    String uid,
  ) {
    return FeedItem(
      id: entity.documentId,
      tags: entity.tags,
      timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
      timePostedString:
          timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
      message: entity.postMessage,
      name: entity.fullName != null ? entity.fullName : entity.churchName,
      userImage: entity.image ?? "",
      isPoll: entity.type == PostType.poll.index,
      postImages: _getPostImages(entity),
      userId: entity.ownerId,
      isLiked: (entity.likes ?? []).contains(uid),
      isMine: entity.ownerId == uid,
      abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
      isShared: entity.isPostPrivate == 1,
    );
  }

  static List<CommentItem> _entitiesToCommentItems(
    List<CommentEntity> entities,
    String uid,
  ) {
    return entities.map((entity) {
      return CommentItem(
        id: entity.documentId,
        fullName: (entity.fullName ?? entity.churchName) ?? "",
        message: entity.postMessage,
        image: entity.image ?? "",
        datePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        isGif: entity.isGIF ?? false,
        gif: entity.imagePath,
        owner: entity.ownerId,
        userId: entity.uid,
      );
    }).toList();
  }

  static Stream<PostDetailsState> _getPostDetails(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    FirestoreCommentRepository commentRepository,
    String postId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        postRepository,
        commentRepository,
        postId,
      );
    });
  }

  static List<String> _getPostImages(PostEntity entity) {
    List<String> images = List<String>();

    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        images = entity.postData.map((data) => data.imageUrl).toList();
      }
    }

    return images;
  }
}
