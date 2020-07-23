import 'dart:async';

import '../../util/post_utils.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/post_entity.dart';
import './feed_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;

const _kInitialFeedListState =
    FeedListState(error: null, isLoading: true, feedItems: []);

class FeedBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final Function(String) postToLikeChanged;
  final Function(bool) likePostChanged;
  final Function() saveLikeValue;

  ///
  /// Output streams
  ///
  final ValueStream<FeedListState> feedListState$;
  final Stream<FeedItemLikeMessage> message$;
  final ValueStream isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  FeedBloc._({
    @required this.saveLikeValue,
    @required this.postToLikeChanged,
    @required this.likePostChanged,
    @required this.feedListState$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory FeedBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final feedItemToLikeSubject = BehaviorSubject<String>.seeded(null);
    final postLikeSubject = BehaviorSubject<bool>.seeded(false);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final savePostLikeSubject = PublishSubject<void>();

    ///
    /// Streams
    ///
    final message$ = savePostLikeSubject
        .switchMap((_) => performSave(
              postRepository,
              postLikeSubject.value,
              (userBloc.loginState$.value as LoggedInUser).uid,
              feedItemToLikeSubject.value,
              isLoadingSubject,
            ))
        .publish();

    final feedListState$ = _getFeedList(
      userBloc,
      postRepository,
    ).publishValueSeeded(_kInitialFeedListState);

    final subscriptions = <StreamSubscription>[
      feedListState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      postLikeSubject,
      isLoadingSubject,
    ];

    return FeedBloc._(
        saveLikeValue: () => savePostLikeSubject.add(null),
        likePostChanged: postLikeSubject.add,
        postToLikeChanged: feedItemToLikeSubject.add,
        isLoading$: isLoadingSubject,
        message$: message$,
        feedListState$: feedListState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  @override
  void dispose() => _dispose;

  static Stream<FeedListState> _toState(
    LoginState loginState,
    FirestorePostRepository postRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialFeedListState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(postRepository.getByAdmin(),
          postRepository.postsByUser(uid: loginState.uid), (byAdmin, userFeed) {
        var feed = _entitiesToFeedItems(byAdmin, loginState.uid);
        var userPosts = _entitiesToFeedItems(userFeed, loginState.uid);

        feed.addAll(userPosts);
        feed.sort((a, b) => b.timePosted.compareTo(a.timePosted));

        return _kInitialFeedListState.copyWith(
          isLoading: false,
          feedItems: feed,
        );
      }).startWith(_kInitialFeedListState).onErrorReturnWith((e) {
        return _kInitialFeedListState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialFeedListState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<FeedItem> _entitiesToFeedItems(
    List<PostEntity> entities,
    String uid,
  ) {
    return entities.toSet().map((entity) {
      return FeedItem(
        id: entity.documentId,
        tags: entity.tags,
        timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        timePostedString:
            timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
        message: entity.postMessage,
        name: entity.fullName != null ? entity.fullName : entity.churchName,
        userImage: entity.image,
        userId: entity.ownerId,
        isPoll: entity.type == PostType.poll.index,
        postImages: _getPostImages(entity),
        isMine: entity.ownerId == uid,
        isLiked: entity.likes != null ? entity.likes.contains(uid) : false,
        abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
        isShared: entity.isPostPrivate == 1,
      );
    }).toList();
  }

  static Stream<FeedListState> _getFeedList(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        postRepository,
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

  static Stream<FeedItemLikeMessage> performSave(
    FirestorePostRepository postRepository,
    bool shouldLike,
    String uid,
    String postId,
    Sink<bool> isLoadingSink,
  ) async* {
    print('[DEBUG] FeedBloc#performSave');
    try {
      isLoadingSink.add(true);
      await postRepository.likeOrUnlikePost(
        shouldLike: shouldLike,
        postId: postId,
        userId: uid,
      );
      yield FeedItemLikeSuccess();
    } catch (e) {
      yield FeedItemLikeError(e);
    } finally {
      isLoadingSink.add(false);
    }
  }
}
