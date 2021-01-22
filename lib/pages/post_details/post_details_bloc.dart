import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/models/old/shared_post.dart';
import '../../util/post_utils.dart';
import '../comments/comments_state.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../data/comment/firestore_comment_repository.dart';
import '../../models/old/post_entity.dart';
import '../../models/old/comment_entity.dart';
import '../../models/old/comment_reply.dart';
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
  final Function(String) postToLikeChanged;
  final Function(bool) likePostChanged;
  final Function() saveLikeValue;
  final Function(String) deletePost;
  final Function(String) unconnect;
  final Function(FeedItem, String) share;
  final Function(String, int) answerPoll;

  ///
  /// Output streams
  ///
  final ValueStream<PostDetailsState> postDetailsState$;
  final Stream<FeedUnconnectMessage> unconnectMessage$;
  final Stream<FeedDeleteMessage> deleteMessage$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  PostDetailsBloc._({
    @required this.unconnect,
    @required this.deletePost,
    @required this.saveLikeValue,
    @required this.postToLikeChanged,
    @required this.likePostChanged,
    @required this.share,
    @required this.answerPoll,
    @required this.postDetailsState$,
    @required this.unconnectMessage$,
    @required this.deleteMessage$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory PostDetailsBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
    @required FirestoreCommentRepository commentRepository,
    @required FirestoreUserRepository userRepository,
    @required String postId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(commentRepository != null, 'commentRepository cannot be null');
    assert(postId != null, 'postId cannot be null');

    ///
    /// Stream controllers
    ///
    final feedItemToLikeSubject = BehaviorSubject<String>.seeded(null);
    final postLikeSubject = BehaviorSubject<bool>.seeded(false);
    final savePostLikeSubject = PublishSubject<void>();
    final unconnectSubject = PublishSubject<String>();
    final deletePostSubject = PublishSubject<String>();

    ///
    /// Streams
    ///
    final deleteMessage$ = deletePostSubject
        .switchMap((post) => performDelete(
              postRepository,
              post,
            ))
        .publish();

    final unconnectMessage$ = unconnectSubject
        .switchMap((user) => performUnconnect(
              userRepository,
              (userBloc.loginState$.value as LoggedInUser).uid,
              user,
            ))
        .publish();

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
        unconnect: (user) => unconnectSubject.add(user),
        deletePost: (post) => deletePostSubject.add(post),
        saveLikeValue: () => savePostLikeSubject.add(null),
        likePostChanged: postLikeSubject.add,
        postToLikeChanged: feedItemToLikeSubject.add,
        share: (post, message) =>
            _sharePost(post, message, userBloc, postRepository),
        answerPoll: (poll, answerIndex) =>
            _answerPoll(poll, answerIndex, userBloc, postRepository),
        postDetailsState$: postDetailsState$,
        deleteMessage$: deleteMessage$,
        unconnectMessage$: unconnectMessage$,
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
      return Rx.combineLatest2(
        postRepository.postById(postId: postId),
        commentRepository.getByPost(postId),
        (post, comments) {
          return _kInitialPostDetailsState.copyWith(
            postDetails:
                _entityToPostItem(post, loginState.uid, loginState.mutedChats),
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
    List<String> muted,
  ) {
    return FeedItem(
        id: entity.documentId,
        tags: entity.tags,
        timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        timePostedString:
            timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
        message: entity.postMessage,
        name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
        userImage: entity.image ?? "",
        isPoll: entity.type == PostType.poll.index,
        postImages: _getPostImages(entity),
        userId: entity.ownerId,
        isLiked: (entity.likes ?? []).contains(uid),
        isMine: entity.ownerId == uid,
        abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
        isShared: entity.isPostPrivate == 1,
        pollData: entity.pollData ?? [],
        likes: entity.likes ?? [],
        sharedPost: entity.sharedPost != null
            ? _entitiyToSharedItem(entity.sharedPost, uid, muted)
            : null,
        type: (entity.postData != null && entity.postData.isNotEmpty)
            ? entity.postData[0].type ?? 0
            : 0);
  }

  static List<CommentItem> _entitiesToCommentItems(
    List<CommentEntity> entities,
    String uid,
  ) {
    entities.sort((a, b) => b.time.compareTo(a.time));

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
        isMine: entity.uid == uid,
        replies: _entitiesToReplyItems(entity.replies ?? [], uid),
        isLiked: (entity.likes ?? []).contains(uid),
        likes: entity.likes ?? [],
      );
    }).toList();
  }

  static List<CommentItem> _entitiesToReplyItems(
    List<CommentReply> entities,
    String uid,
  ) {
    return entities.map((entity) {
      return CommentItem(
        id: '',
        userId: entity.ownerId,
        fullName: (entity.fullName ?? entity.churchName) ?? "",
        message: entity.postMessage,
        image: entity.image ?? "",
        datePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        isGif: entity.isGIF ?? false,
        gif: entity.imagePath,
        owner: entity.ownerId,
        replies: [],
        isMine: entity.ownerId == uid,
        likes: [],
        isLiked: false,
      );
    }).toList();
  }

  static FeedItem _entitiyToSharedItem(
    SharedPost entity,
    String uid,
    List<String> muted,
  ) {
    return FeedItem(
        id: null,
        tags: entity.tags,
        timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        timePostedString:
            timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
        message: entity.postMessage,
        name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
        userImage: entity.image,
        userId: entity.ownerId,
        isPoll: entity.type == PostType.poll.index,
        postImages: _getSharedImages(entity),
        isMine: entity.ownerId == uid,
        isLiked: entity.likes != null ? entity.likes.contains(uid) : false,
        abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
        isShared: entity.isShared ?? false,
        pollData: entity.pollData ?? [],
        likes: entity.likes ?? [],
        sharedPost: null,
        type: (entity.postData != null && entity.postData.isNotEmpty)
            ? entity.postData[0].type ?? 0
            : 0);
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

  static List<String> _getSharedImages(SharedPost entity) {
    List<String> images = List<String>();

    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        images = entity.postData.map((data) => data.imageUrl).toList();
      }
    }

    return images;
  }

  static Stream<FeedDeleteMessage> performDelete(
    FirestorePostRepository postRepository,
    String postId,
  ) async* {
    print('[DEBUG] PostDetailsBloc#performDelete');
    try {
      await postRepository.deletePost(postId);
      yield FeedDeleteSuccess();
    } catch (e) {
      yield FeedDeleteError(e);
    }
  }

  static Stream<FeedUnconnectMessage> performUnconnect(
    FirestoreUserRepository userRepository,
    String userId,
    String userToUnfollow,
  ) async* {
    print('[DEBUG] PostDetailsBloc#performUnconnect');
    try {
      await userRepository.removeConnection(userId, userToUnfollow);
      yield FeedUnconnectSuccess();
    } catch (e) {
      yield FeedUnconnectError(e);
    }
  }

  static Future<void> _sharePost(
    FeedItem post,
    String message,
    UserBloc userBloc,
    FirestorePostRepository postRepository,
  ) async {
    print('[DEBUG] PostDetailsBloc#sharePost');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      await postRepository.sharePost(
        post.id,
        loginState.isAdmin,
        loginState.uid,
        loginState.fullName,
        loginState.email,
        loginState.image,
        loginState.token,
        loginState.isVerified,
        loginState.isChurch,
        message,
        loginState.connections,
      );
    }
  }

  static Future<void> _answerPoll(
    String poll,
    int answerIndex,
    UserBloc userBloc,
    FirestorePostRepository postRepository,
  ) async {
    print('[DEBUG] PostDetailsBloc#answerPoll');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      await postRepository.answerPoll(
        poll,
        answerIndex,
        loginState.uid,
      );
    }
  }
}
