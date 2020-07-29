import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/data/post/firestore_post_repository.dart';
import 'package:treeapp/models/old/post_entity.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/comment/firestore_comment_repository.dart';
import '../../models/old/comment_entity.dart';
import '../../models/old/comment_reply.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './comments_state.dart';

bool _isCommentValid(String comment) {
  return comment.isNotEmpty;
}

const _kInitialCommentsState = CommentsState(
  comments: [],
  postDetails: null,
  isLoading: true,
  error: null,
);

class CommentsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function() addComment;
  Function(String) commentChanged;
  Function(String) gifChanged;
  Function(bool) isGifChanged;

  ///
  /// Output streams
  ///
  final ValueStream<CommentsState> commentsState$;
  final Stream<CommentEmptyError> commentError$;
  final Stream<CommentAddedMessage> message$;
  final ValueStream<bool> isLoading$;

  final ValueStream<bool> isGif$;
  final ValueStream<String> gif$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  CommentsBloc._({
    @required this.addComment,
    @required this.commentChanged,
    @required this.gifChanged,
    @required this.isGifChanged,
    @required this.commentsState$,
    @required this.commentError$,
    @required this.message$,
    @required this.isLoading$,
    @required this.isGif$,
    @required this.gif$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory CommentsBloc({
    @required UserBloc userBloc,
    @required FirestoreCommentRepository commentRepository,
    @required FirestorePostRepository postRepository,
    @required String postId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(commentRepository != null, 'commentRepository cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(postId != null, 'postId cannot be null');

    ///
    /// Stream controllers
    ///
    final addCommentSubject = PublishSubject<void>(sync: true);
    final commentSubject = BehaviorSubject<String>.seeded('');
    final gifSubject = BehaviorSubject<String>.seeded('');
    final isGifSubject = BehaviorSubject<bool>.seeded(false);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final commentError$ = commentSubject.map((comment) {
      if (_isCommentValid(comment)) return null;
      return const CommentEmptyError();
    });

    final allFieldsAreValid$ = Rx.combineLatest(
      [
        commentError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = addCommentSubject
        .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
        .where((isValid) => isValid)
        .exhaustMap((_) => saveComment(
              userBloc,
              commentRepository,
              postId,
              commentSubject.value,
              isGifSubject.value,
              gifSubject.value,
              isLoadingSubject,
            ))
        .publish();

    final commentsState$ = _getComments(
      userBloc,
      commentRepository,
      postRepository,
      postId,
    ).publishValueSeeded(_kInitialCommentsState);

    final subscriptions = <StreamSubscription>[
      commentsState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      commentSubject,
      gifSubject,
      isGifSubject,
      isLoadingSubject,
    ];

    return CommentsBloc._(
        addComment: () => addCommentSubject.add(null),
        commentChanged: commentSubject.add,
        isGifChanged: isGifSubject.add,
        gifChanged: gifSubject.add,
        isGif$: isGifSubject.stream,
        gif$: gifSubject.stream,
        commentsState$: commentsState$,
        commentError$: commentError$,
        message$: message$,
        isLoading$: isLoadingSubject,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<CommentsState> _toState(
    LoginState loginState,
    FirestoreCommentRepository commentRepository,
    FirestorePostRepository postRepository,
    String postId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialCommentsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(commentRepository.getByPost(postId),
          postRepository.postById(postId: postId), (comments, post) {
        (comments as List<CommentEntity>)
            .sort((a, b) => a.time.compareTo(b.time));

        return _kInitialCommentsState.copyWith(
          isLoading: false,
          comments: _entitiesToCommentItems(comments, loginState.uid),
          postDetails: _entityToPostItem(post, loginState.uid),
        );
      }).startWith(_kInitialCommentsState).onErrorReturnWith((e) {
        return _kInitialCommentsState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialCommentsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<CommentItem> _entitiesToCommentItems(
    List<CommentEntity> entities,
    String uid,
  ) {
    return entities.map((entity) {
      return CommentItem(
        id: entity.documentId,
        userId: entity.ownerId,
        fullName: (entity.fullName ?? entity.churchName) ?? "",
        message: entity.postMessage,
        image: entity.image ?? "",
        datePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        isGif: entity.isGIF ?? false,
        gif: entity.imagePath,
        owner: entity.ownerId,
        replies: _entitiesToReplyItems(entity.replies ?? [], uid),
        isMine: entity.ownerId == uid,
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
        isGif: false,
        gif: '',
        owner: entity.ownerId,
        replies: [],
        isMine: entity.ownerId == uid,
      );
    }).toList();
  }

  static PostItem _entityToPostItem(
    PostEntity entity,
    String uid,
  ) {
    return PostItem(
      isMuted: (entity.muted ?? []).contains(uid),
      id: entity.id,
    );
  }

  static Stream<CommentsState> _getComments(
    UserBloc userBloc,
    FirestoreCommentRepository commentRepository,
    FirestorePostRepository postRepository,
    String postId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        commentRepository,
        postRepository,
        postId,
      );
    });
  }

  static Stream<CommentAddedMessage> saveComment(
    UserBloc userBloc,
    FirestoreCommentRepository commentRepository,
    String postId,
    String comment,
    bool isGif,
    String gif,
    Sink<bool> isLoading,
  ) async* {
    print('[DEBUG] CommentsBloc#saveComment');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoading.add(true);
        await commentRepository.saveComment(
          null,
          loginState.isAdmin,
          loginState.fullName,
          loginState.isAdmin,
          loginState.isChurch,
          loginState.image,
          loginState.isVerified,
          loginState.uid,
          postId,
          comment,
          isGif,
          gif,
          loginState.token,
        );

        yield CommentAddedSuccess();
      } catch (e) {
        yield CommentAddedError(e);
      } finally {
        isLoading.add(false);
      }
    } else {
      yield CommentAddedError(NotLoggedInError());
    }
  }
}
