import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/comment/firestore_comment_repository.dart';
import '../../models/old/comment_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './comments_state.dart';

bool _isCommentValid(String comment) {
  return comment.isNotEmpty;
}

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
  Function(String) commentChanged;
  Function(String) gifChanged;
  Function(bool) isGifChanged;

  /// 
  /// Output streams
  ///
  final ValueStream<CommentsState> commentsState$;
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
    @required this.message$,
    @required this.isLoading$,
    @required this.isGif$,
    @required this.gif$,
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
    final addCommentSubject = PublishSubject<void>(sync: true);
    final commentSubject = BehaviorSubject<String>.seeded('');
    final gifSubject = BehaviorSubject<String>.seeded('');
    final isGifSubject = BehaviorSubject<bool>.seeded(false);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    /// 
    /// Streams
    /// 
    final message$ = addCommentSubject
      .exhaustMap(
        (_) => saveComment(
          userBloc,
          commentRepository,
          isLoadingSubject,
        )
      ).publish();

    final commentsState$ = _getComments(
      userBloc,
      commentRepository,
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
      message$: message$,
      isLoading$: isLoadingSubject,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
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
        userId: entity.ownerId,
        fullName: (entity.fullName ?? entity.churchName) ?? "",
        message: entity.postMessage,
        image: entity.image ?? "",
        datePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        isGif: entity.isGIF ?? false,
        gif: entity.imagePath,
        owner: entity.ownerId,
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
  
  static Stream<CommentAddedMessage> saveComment(
    UserBloc userBloc,
    FirestoreCommentRepository commentRepository,
    Sink<bool> isLoading,
  ) async* {
    print('[DEBUG] CommentsBloc#saveComment');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoading.add(true);
        await commentRepository.getByPost(
          '1234',
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