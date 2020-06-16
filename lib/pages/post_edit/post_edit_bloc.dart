import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../models/old/post_entity.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import './post_edit_state.dart';

const _kInitialPostEditState = EditPostState(
  error: null,
  postItem: null,
  isLoading: true,
);

class EditPostBloc implements BaseBloc {
  /// 
  /// Input functions
  /// 
  final void Function() savePost;
  final void Function(bool) postIsPublicChanged;
  final void Function(bool) postForConnectionsOnlyChanged;
  final void Function(String) postMessageChanged;
  final void Function(List<String>) postImagesChanged;
  final void Function(List<String>) postVideosChanged;
  final void Function(List<String>) postTagsChanged;

  /// 
  /// Output streams
  ///
  final ValueStream<EditPostState> postEditState$;
  final Stream<PostAddedMessage> message$;
  final ValueStream<bool> isLoading$;
  final ValueStream<bool> postIsPublic$;

  /// 
  /// Clean up
  ///
  final void Function() _dispose;

  EditPostBloc._({
    @required this.savePost,
    @required this.postIsPublicChanged,
    @required this.postForConnectionsOnlyChanged,
    @required this.postMessageChanged,
    @required this.postImagesChanged,
    @required this.postVideosChanged,
    @required this.postTagsChanged,
    @required this.postEditState$,
    @required this.postIsPublic$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory EditPostBloc({
    String postId,
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
  }) {
    /// 
    /// Assert
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');

    /// 
    /// Stream controller
    /// 
    final isPublicSubject = BehaviorSubject<bool>.seeded(false);
    final isOnlyForConnectionsSubject = BehaviorSubject<bool>.seeded(false);
    final messageSubject = BehaviorSubject<String>.seeded('');
    final imagesSubject = BehaviorSubject<List<String>>.seeded(List<String>());
    final videosSubject = BehaviorSubject<List<String>>.seeded(List<String>());
    final tagsSubject = BehaviorSubject<List<String>>.seeded(List<String>());
    final savePostSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    /// 
    /// Streams
    ///
    final message$ = savePostSubject
      .switchMap((_) => performSave(
        postId,
        userBloc,
        postRepository,
        isPublicSubject.value,
        isOnlyForConnectionsSubject.value,
        messageSubject.value,
        imagesSubject.value,
        videosSubject.value,
        tagsSubject.value,
        isLoadingSubject,
      ),
    ).publish();

    final postEditState$ = _getPostDetails(
      userBloc,
      postRepository,
      postId,
    ).publishValueSeeded(_kInitialPostEditState);

    /// 
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      postEditState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      isPublicSubject,
      isOnlyForConnectionsSubject,
      messageSubject,
      imagesSubject,
      videosSubject,
      tagsSubject,
      isLoadingSubject,
    ];

    return EditPostBloc._(
      savePost: () => savePostSubject.add(null),
      postIsPublicChanged: isPublicSubject.add,
      postForConnectionsOnlyChanged: isOnlyForConnectionsSubject.add,
      postMessageChanged: messageSubject.add,
      postImagesChanged: imagesSubject.add,
      postVideosChanged: videosSubject.add,
      postTagsChanged: tagsSubject.add,
      postIsPublic$: isPublicSubject.stream,
      isLoading$: isLoadingSubject,
      message$: message$,
      postEditState$: postEditState$,
      dispose: () async {
        Future.wait(subscriptions.map((s) => s.cancel()));
        Future.wait((controllers.map((c) => c.close())));
      }
    );
  }

  static Stream<EditPostState> _toState(
    LoginState loginState,
    FirestorePostRepository postRepository,
    String postId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialPostEditState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (postId != null) {
        return postRepository.postById(postId: postId)
          .map((entity) {
            return _entityToPostItem(entity);
          })
          .map((postItem) {
            return _kInitialPostEditState.copyWith(
              postItem: postItem,
              isLoading: false,
            );
          })
          .startWith(_kInitialPostEditState)
          .onErrorReturnWith((e) {
            return _kInitialPostEditState.copyWith(
              error: e,
              isLoading: false,
            );
          });
      } else {
        return Stream.value(
          _kInitialPostEditState.copyWith(
            isLoading: false,
          ),
        );
      }
    }

    return Stream.value(
      _kInitialPostEditState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static FeedPostItem _entityToPostItem(
    PostEntity entity,
  ) {
    return FeedPostItem(
      id: entity.documentId,
      message: entity.postMessage,
      connectionsOnly: false,
      isPublic: entity.isPostPrivate == 0,
      tagged: entity.tags,
      images: entity.postData.where((p) => p.type == 0).map((p) => p.imageUrl).toList(),
      videos: entity.postData.where((p) => p.type == 1).map((p) => p.imageUrl).toList(),
    );
  }

  static Stream<EditPostState> _getPostDetails(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    String postId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        postRepository,
        postId,
      );
    });
  }

  static Stream<PostAddedMessage> performSave(
    String postId,
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    bool isPublic,
    bool isOnlyForConnections,
    String messageSubject,
    List<String> imagesSubject,
    List<String> videosSubject,
    List<String> tagsSubject,
    Sink<bool> isLoadingSubject,
  ) async* {
    print('[DEBUG] EditPostBloc#performSave');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        yield PostAddedMessageSuccess();
      } catch (e) {
        yield PostAddedMessageError(e);
      }
    } else {
      yield PostAddedMessageError(NotLoggedInError());
    }
  }
}