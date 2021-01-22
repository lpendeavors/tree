import 'dart:async';

import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/models/old/shared_post.dart';

import '../../util/post_utils.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../data/notification/firestore_notification_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/post_entity.dart';
import '../../models/old/notification_entity.dart';
import './feed_state.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';

const _kInitialFeedListState = FeedListState(
  error: null,
  hasNotifications: false,
  isLoading: true,
  feedItems: [],
);

class FeedBloc implements BaseBloc {
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
  final ValueStream<FeedListState> feedListState$;
  final Stream<FeedItemLikeMessage> message$;
  final Stream<FeedUnconnectMessage> unconnectMessage$;
  final Stream<FeedDeleteMessage> deleteMessage$;
  final ValueStream isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  FeedBloc._({
    @required this.unconnect,
    @required this.deletePost,
    @required this.saveLikeValue,
    @required this.postToLikeChanged,
    @required this.likePostChanged,
    @required this.share,
    @required this.answerPoll,
    @required this.feedListState$,
    @required this.unconnectMessage$,
    @required this.deleteMessage$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory FeedBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
    @required FirestoreNotificationRepository notificationRepository,
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(notificationRepository != null,
        'notificationRepository cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final feedItemToLikeSubject = BehaviorSubject<String>.seeded(null);
    final postLikeSubject = BehaviorSubject<bool>.seeded(false);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final savePostLikeSubject = PublishSubject<void>();
    final unconnectSubject = PublishSubject<String>();
    final deletePostSubject = PublishSubject<String>();

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

    final feedListState$ = _getFeedList(
      userBloc,
      postRepository,
      notificationRepository,
    ).publishValueSeeded(_kInitialFeedListState);

    final subscriptions = <StreamSubscription>[
      feedListState$.connect(),
      message$.connect(),
      unconnectMessage$.connect(),
      deleteMessage$.connect(),
    ];

    final controllers = <StreamController>[
      postLikeSubject,
      isLoadingSubject,
      feedItemToLikeSubject,
    ];

    return FeedBloc._(
        unconnect: (user) => unconnectSubject.add(user),
        deletePost: (post) => deletePostSubject.add(post),
        saveLikeValue: () => savePostLikeSubject.add(null),
        likePostChanged: postLikeSubject.add,
        postToLikeChanged: feedItemToLikeSubject.add,
        share: (post, message) =>
            _sharePost(post, message, userBloc, postRepository),
        answerPoll: (poll, answerIndex) =>
            _answerPoll(poll, answerIndex, userBloc, postRepository),
        isLoading$: isLoadingSubject,
        message$: message$,
        deleteMessage$: deleteMessage$,
        unconnectMessage$: unconnectMessage$,
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
    FirestoreNotificationRepository notificationRepository,
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
      return Rx.combineLatest4(
          postRepository.getByAdmin(),
          postRepository.postsByUser(uid: loginState.uid),
          postRepository.postsByOwner(uid: loginState.uid),
          notificationRepository.getByOwner(loginState.uid),
          (byAdmin, userFeed, myPosts, notifications) {
        var feed = _entitiesToFeedItems(
            byAdmin, loginState.uid, loginState.mutedChats);
        var userPosts = _entitiesToFeedItems(
            userFeed, loginState.uid, loginState.mutedChats);
        var mine = _entitiesToFeedItems(
            myPosts, loginState.uid, loginState.mutedChats);

        userPosts
            .removeWhere((p) => feed.map((f) => f.id).toList().contains(p.id));

        var hasNotifications =
            _entitiesToNewNotifications(notifications, loginState.uid);

        feed.addAll(userPosts);
        feed.addAll(mine);
        feed.sort((a, b) => b.timePosted.compareTo(a.timePosted));

        return _kInitialFeedListState.copyWith(
          isLoading: false,
          feedItems: feed.toSet().toList(),
          hasNotifications: hasNotifications,
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
    List<String> muted,
  ) {
    return entities.toSet().map((entity) {
      return FeedItem(
        id: entity.documentId,
        tags: entity.tags,
        timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        timePostedString:
            timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
        message: entity.postMessage,
        name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
        userImage: entity.image,
        userId: entity.ownerId,
        isPoll: entity.type == PostType.poll.index,
        postImages: _getPostImages(entity),
        isMine: entity.ownerId == uid,
        isLiked: entity.likes != null ? entity.likes.contains(uid) : false,
        abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
        isShared: entity.isShared ?? false,
        pollData: entity.pollData ?? [],
        likes: entity.likes ?? [],
        sharedPost: entity.sharedPost != null
            ? _entitiyToSharedItem(entity.sharedPost, uid, muted)
            : null,
        type: (entity.postData != null && entity.postData.isNotEmpty)
            ? entity.postData[0].type ?? 0
            : 0,
      );
    }).where((item) {
      return !(muted ?? []).contains(item.id);
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
          : 0,
    );
  }

  static bool _entitiesToNewNotifications(
    List<NotificationEntity> notifications,
    String uid,
  ) {
    var newNotifications = List<NotificationEntity>();
    notifications.forEach((n) {
      var readBy = n.readBy ?? [];
      if (!readBy.contains(uid)) {
        newNotifications.add(n);
      }
    });

    return newNotifications.length > 0;
  }

  static Stream<FeedListState> _getFeedList(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    FirestoreNotificationRepository notificationRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        postRepository,
        notificationRepository,
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

  static Stream<FeedUnconnectMessage> performUnconnect(
    FirestoreUserRepository userRepository,
    String userId,
    String userToUnfollow,
  ) async* {
    print('[DEBUG] FeedBloc#performUnconnect');
    try {
      await userRepository.removeConnection(userId, userToUnfollow);
      yield FeedUnconnectSuccess();
    } catch (e) {
      yield FeedUnconnectError(e);
    }
  }

  static Stream<FeedDeleteMessage> performDelete(
    FirestorePostRepository postRepository,
    String postId,
  ) async* {
    print('[DEBUG] FeedBloc#performDelete');
    try {
      await postRepository.deletePost(postId);
      yield FeedDeleteSuccess();
    } catch (e) {
      yield FeedDeleteError(e);
    }
  }

  static Future<void> _sharePost(
    FeedItem post,
    String message,
    UserBloc userBloc,
    FirestorePostRepository postRepository,
  ) async {
    print('[DEBUG] FeedBloc#sharePost');
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
    print('[DEBUG] FeedBloc#answerPoll');
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
