import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/old/post_data.dart';
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
  final void Function(List<String>) postMediaChanged;
  final void Function(int) postMediaTypeChanged;
  final void Function(String) postVideoThumbnailChanged;
  final void Function(List<Map<String, String>>) taggedChanged;

  ///
  /// Output streams
  ///
  final ValueStream<EditPostState> postEditState$;
  final Stream<PostAddedMessage> message$;
  final ValueStream<bool> isLoading$;
  final ValueStream<bool> postIsPublic$;
  final ValueStream<List<String>> postMedia$;
  final ValueStream<int> postMediaType$;
  final ValueStream<String> postVideoThumbnail$;
  final ValueStream<List<Map<String, String>>> tagged$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  EditPostBloc._({
    @required this.savePost,
    @required this.postIsPublicChanged,
    @required this.postForConnectionsOnlyChanged,
    @required this.postMessageChanged,
    @required this.postMediaChanged,
    @required this.postMediaTypeChanged,
    @required this.postVideoThumbnailChanged,
    @required this.taggedChanged,
    @required this.postEditState$,
    @required this.postIsPublic$,
    @required this.postMedia$,
    @required this.postMediaType$,
    @required this.postVideoThumbnail$,
    @required this.tagged$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory EditPostBloc({
    String postId,
    String groupId,
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
    final isPublicSubject = BehaviorSubject<bool>.seeded(true);
    final isOnlyForConnectionsSubject = BehaviorSubject<bool>.seeded(false);
    final messageSubject = BehaviorSubject<String>.seeded('');
    final taggedSubject = BehaviorSubject<List<Map<String, String>>>.seeded([]);
    final postMediaSubject =
        BehaviorSubject<List<String>>.seeded(List<String>());
    final postMediaTypeSubject = BehaviorSubject<int>.seeded(null);
    final postVideoThumbnailSubject = BehaviorSubject<String>.seeded('');
    final savePostSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final message$ = savePostSubject
        .switchMap(
          (_) => performSave(
            postId,
            userBloc,
            postRepository,
            isPublicSubject.value,
            messageSubject.value,
            postMediaSubject.value,
            postVideoThumbnailSubject.value,
            taggedSubject.value,
            groupId,
            postMediaTypeSubject.value,
            isLoadingSubject,
          ),
        )
        .publish();

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
      postMediaSubject,
      postMediaTypeSubject,
      postVideoThumbnailSubject,
      taggedSubject,
      isLoadingSubject,
    ];

    return EditPostBloc._(
        savePost: () => savePostSubject.add(null),
        postIsPublicChanged: isPublicSubject.add,
        postForConnectionsOnlyChanged: isOnlyForConnectionsSubject.add,
        postMessageChanged: messageSubject.add,
        postMediaChanged: postMediaSubject.add,
        postMediaTypeChanged: postMediaTypeSubject.add,
        postVideoThumbnailChanged: postVideoThumbnailSubject.add,
        taggedChanged: taggedSubject.add,
        postIsPublic$: isPublicSubject.stream,
        postMedia$: postMediaSubject.stream,
        postMediaType$: postMediaTypeSubject.stream,
        postVideoThumbnail$: postVideoThumbnailSubject.stream,
        tagged$: taggedSubject.stream,
        isLoading$: isLoadingSubject,
        message$: message$,
        postEditState$: postEditState$,
        dispose: () async {
          Future.wait(subscriptions.map((s) => s.cancel()));
          Future.wait((controllers.map((c) => c.close())));
        });
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
        return postRepository
            .postById(postId: postId)
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
      images: (entity.postData ?? List<PostData>())
          .where((p) => p.type == 1)
          .map((p) => p.imageUrl)
          .toList(),
      videos: (entity.postData ?? List<PostData>())
          .where((p) => p.type == 2)
          .map((p) => p.imageUrl)
          .toList(),
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
    String message,
    List<String> postMedia,
    String postVideoThumbnail,
    List<Map<String, String>> tags,
    String groupId,
    int mediaType,
    Sink<bool> isLoadingSubject,
  ) async* {
    print('[DEBUG] EditPostBloc#performSave');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        postRepository.savePost(
          postId,
          loginState.isAdmin,
          loginState.fullName,
          loginState.image,
          loginState.isAdmin,
          loginState.isChurch,
          groupId != null ? true : false,
          isPublic,
          isPublic ? 1 : 0,
          false,
          loginState.isVerified,
          loginState.uid,
          loginState.connections,
          postMedia ?? [],
          mediaType,
          message,
          loginState.token,
          0,
          groupId,
          tags.map((t) => t["id"]).toList(),
        );
        yield PostAddedMessageSuccess();
      } catch (e) {
        print(e);
        yield PostAddedMessageError(e);
      }
    } else {
      yield PostAddedMessageError(NotLoggedInError());
    }
  }
}
