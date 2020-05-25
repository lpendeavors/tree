import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/comment/firestore_comment_repository.dart';
import '../../models/old/comment_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './comments_state.dart';

const _kInitialCommentsState = CommentsState(
  comments: [],
  isLoading: true,
  error: null,
);

class CommentsBloc implements BaseBloc {
  /// 
  /// Input functions
  /// 
  Function() addComment;

  /// 
  /// Output streams
  ///
  final ValueStream<CommentsState> commentsState$;
  final Stream<CommentAddedMessage> message$;

  /// 
  /// Clean up
  ///
  final void Function() _dispose;

  CommentsBloc._({
    @required this.addComment,
    @required this.commentsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory CommentsBloc({
    @required UserBloc userBloc,
    @required FirestoreCommentRepository commentRepository,
    @required String postId,
  }) {
    /// 
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(commentRepository != null, 'commentRepository cannot be null');
    assert(postId != null, 'postId cannot be null');

    /// 
    /// Stream controllers
    ///
    final addComment = PublishSubject<void>(sync: true);

    /// 
    /// Streams
    /// 
    final message$ = _getCommentMessage(
      addComment,
      userBloc,
      commentRepository,
    );

    final commentsState$ = _getComments(
      userBloc,
      commentRepository,
      postId,
    ).publishValueSeeded(_kInitialCommentsState);

    final subscriptions = <StreamSubscription>[
      commentsState$.connect(),
      message$.connect(),
    ];

    return CommentsBloc._(
      addComment: () => addComment.add(null),
      commentsState$: commentsState$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<CommentsState> _toState(
    LoginState loginState,
    FirestoreCommentRepository commentRepository,
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
      return commentRepository.getByPost(postId)
        .map((entities) {
          entities.sort((a, b) => a.time.compareTo(b.time));
          return _entitiesToCommentItems(
            entities,
          );
        })
        .map((commentItems) {
          return _kInitialCommentsState.copyWith(
            comments: commentItems,
            isLoading: false,
          );
        })
        .startWith(_kInitialCommentsState)
        .onErrorReturnWith((e) {
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
      );
    }).toList();
  }

  static Stream<CommentsState> _getComments(
    UserBloc userBloc,
    FirestoreCommentRepository commentRepository,
    String postId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        commentRepository,
        postId,
      );
    });
  }
  
  static ConnectableStream<CommentAddedMessage> _getCommentMessage(
    Stream<void> addComment,
    UserBloc userBloc,
    FirestoreCommentRepository commentRepository,
  ) {
    return Rx.combineLatest([
      addComment,
    ], (message) {
      var loginState = userBloc.loginState$.value;
      if (loginState is Unauthenticated) {

      }

      if (loginState is LoggedInUser) {
        // TODO: save comment
      }
    }).publish();
  }
}