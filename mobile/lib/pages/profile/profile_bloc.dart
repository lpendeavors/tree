import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/data/group/firestore_group_repository.dart';
import 'package:treeapp/data/request/firestore_request_repository.dart';
import 'package:treeapp/models/old/shared_post.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import '../../util/post_utils.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../models/old/post_entity.dart';
import '../../pages/feed/feed_state.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './profile_state.dart';
import 'package:timeago/timeago.dart' as timeago;

const _kInitialProfileState = ProfileState(
  profile: null,
  isLoading: true,
  error: null,
  isAdmin: false,
);

const _kInitialRecentFeedState = RecentFeedState(
  feedItems: [],
  isLoading: true,
  error: false,
);

class ProfileBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function(Map<String, String>) sendConnectRequest;
  final void Function() cancelConnectRequest;
  final void Function() acceptConnectRequest;
  final void Function() disconnect;
  final void Function() approveAccount;
  final void Function(File file) setPhoto;
  final void Function() createOrLaunchDM;
  final void Function(String) postToLikeChanged;
  final void Function(bool) likePostChanged;
  final void Function() saveLikeValue;
  final Function(String) deletePost;
  final Function(String) suspendUser;
  final Function(String) deleteUser;
  final Function(String) unconnect;
  final Function(FeedItem, String) share;
  final Function(String, int) answerPoll;

  ///
  /// Output streams
  ///

  final Stream<FeedDeleteMessage> deleteMessage$;
  final Stream<FeedItemLikeMessage> likeMessage$;
  final ValueStream<ProfileState> profileState$;
  final ValueStream<RecentFeedState> recentFeedState$;
  final Stream<MessageCreateMessage> dmState$;
  final ValueStream isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ProfileBloc._({
    @required this.unconnect,
    @required this.share,
    @required this.answerPoll,
    @required this.profileState$,
    @required this.recentFeedState$,
    @required this.dmState$,
    @required this.deleteMessage$,
    @required this.likeMessage$,
    @required this.sendConnectRequest,
    @required this.cancelConnectRequest,
    @required this.acceptConnectRequest,
    @required this.disconnect,
    @required this.approveAccount,
    @required this.setPhoto,
    @required this.createOrLaunchDM,
    @required this.postToLikeChanged,
    @required this.likePostChanged,
    @required this.saveLikeValue,
    @required this.deletePost,
    @required this.suspendUser,
    @required this.deleteUser,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ProfileBloc({
    @required UserBloc userBloc,
    @required String userId,
    @required FirestoreUserRepository userRepository,
    @required FirestorePostRepository postRepository,
    @required FirestoreGroupRepository groupRepository,
    @required FirestoreRequestRepository requestRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(requestRepository != null, 'requestRepository cannot be null');

    ///
    /// Controllers
    ///
    final sendConnectRequestController = PublishSubject<Map<String, String>>();
    final cancelConnectRequestController = PublishSubject<void>();
    final acceptConnectRequestController = PublishSubject<void>();
    final disconnectController = PublishSubject<void>();
    final approveController = PublishSubject<void>();
    final setPhotoController = BehaviorSubject<File>();
    final createOrLaunchDMController = PublishSubject<void>();
    final feedItemToLikeSubject = BehaviorSubject<String>.seeded(null);
    final postLikeSubject = BehaviorSubject<bool>.seeded(false);
    final savePostLikeSubject = PublishSubject<void>();
    final deletePostSubject = PublishSubject<String>();
    final deleteUserSubject = PublishSubject<void>();
    final suspendUserSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final unconnectSubject = PublishSubject<String>();

    final sendConnectRequest$ = sendConnectRequestController
        .exhaustMap((request) => _sendConnectRequest(
            requestRepository, request, userBloc.loginState$.value))
        .publish();
    final cancelConnectRequest$ = cancelConnectRequestController
        .exhaustMap((_) => _cancelConnectRequest(
            userRepository, userId, userBloc.loginState$.value))
        .publish();
    final acceptConnectRequest$ = acceptConnectRequestController
        .exhaustMap((_) => _acceptConnectRequest(
            userRepository, userId, userBloc.loginState$.value))
        .publish();
    final disconnect$ = disconnectController
        .exhaustMap((_) =>
            _disconnect(userRepository, userId, userBloc.loginState$.value))
        .publish();
    final approveAccount$ = approveController
        .exhaustMap((_) => _approveAccount(userRepository, userId))
        .publish();
    final photo$ = setPhotoController
        .exhaustMap(
            (_) => _upload(userRepository, userId, setPhotoController.value))
        .publish();

    final dm$ = createOrLaunchDMController
        .exhaustMap((_) => _createOrLaunch(userRepository, groupRepository,
            userId, userBloc.loginState$.value))
        .publish();

    final deleteMessage$ = deletePostSubject
        .switchMap((post) => performDelete(
              postRepository,
              post,
            ))
        .publish();

    final likeMessage$ = savePostLikeSubject
        .switchMap((_) => saveLikeOrUnlike(
              postRepository,
              postLikeSubject.value,
              (userBloc.loginState$.value as LoggedInUser).uid,
              feedItemToLikeSubject.value,
              isLoadingSubject,
            ))
        .publish();

    final unconnectMessage$ = unconnectSubject
        .switchMap((user) => performUnconnect(
              userRepository,
              (userBloc.loginState$.value as LoggedInUser).uid,
              user,
            ))
        .publish();

    ///
    /// Streams
    ///
    final profileState$ = _getProfile(
      userBloc,
      userId,
      userRepository,
    ).publishValueSeeded(_kInitialProfileState);

    final recentFeedState$ = _getRecentFeed(userBloc, userId, postRepository)
        .publishValueSeeded(_kInitialRecentFeedState);

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      profileState$.connect(),
      recentFeedState$.connect(),
      sendConnectRequest$.connect(),
      cancelConnectRequest$.connect(),
      acceptConnectRequest$.connect(),
      disconnect$.connect(),
      approveAccount$.connect(),
      photo$.connect(),
      dm$.connect(),
      likeMessage$.connect(),
      deleteMessage$.connect(),
      unconnectMessage$.connect(),
    ];

    final controllers = <StreamController>[
      sendConnectRequestController,
      cancelConnectRequestController,
      acceptConnectRequestController,
      disconnectController,
      approveController,
      setPhotoController,
      createOrLaunchDMController,
      postLikeSubject,
      feedItemToLikeSubject,
    ];

    return ProfileBloc._(
        profileState$: profileState$,
        recentFeedState$: recentFeedState$,
        dmState$: dm$,
        isLoading$: isLoadingSubject,
        sendConnectRequest: (request) =>
            sendConnectRequestController.add(request),
        cancelConnectRequest: () => cancelConnectRequestController.add(null),
        acceptConnectRequest: () => acceptConnectRequestController.add(null),
        disconnect: () => disconnectController.add(null),
        approveAccount: () => approveController.add(null),
        setPhoto: (file) => setPhotoController.add(file),
        createOrLaunchDM: () => createOrLaunchDMController.add(null),
        deletePost: (post) => deletePostSubject.add(post),
        saveLikeValue: () => savePostLikeSubject.add(null),
        likePostChanged: postLikeSubject.add,
        postToLikeChanged: feedItemToLikeSubject.add,
        deleteMessage$: deleteMessage$,
        likeMessage$: likeMessage$,
        suspendUser: (user) => _suspendUser(userBloc, userRepository, user),
        deleteUser: (user) => _deleteUser(userBloc, userRepository, user),
        unconnect: (user) => unconnectSubject.add(user),
        share: (post, message) =>
            _sharePost(post, message, userBloc, postRepository),
        answerPoll: (poll, answerIndex) =>
            _answerPoll(poll, answerIndex, userBloc, postRepository),
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<MessageCreateMessage> _createOrLaunch(
    FirestoreUserRepository userRepository,
    FirestoreGroupRepository groupRepository,
    String userID,
    LoginState loginState,
  ) async* {
    if (loginState is LoggedInUser) {
      try {
        var details = await groupRepository.launchDM(userID, loginState);
        yield MessageCreateSuccess(details);
      } catch (e) {
        yield MessageCreateError(e);
      }
    } else {
      yield MessageCreateError(ProfileNotLoggedInError());
    }
  }

  static _sendConnectRequest(
    FirestoreRequestRepository requestRepository,
    Map<String, String> request,
    LoginState loginState,
  ) {
    if (loginState is LoggedInUser) {
      requestRepository.addRequest(
        image: loginState.image,
        toName: request['name'],
        toId: request['id'],
        fromName: loginState.fullName,
        fromId: loginState.uid,
        token: loginState.token,
      );
    }
  }

  static _cancelConnectRequest(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if (loginState is LoggedInUser) {
      userRepository.cancelConnectionRequest(loginState.uid, userID);
    }
  }

  static _acceptConnectRequest(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if (loginState is LoggedInUser) {
      userRepository.acceptConnectionRequest(userID, loginState.uid);
    }
  }

  static _disconnect(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if (loginState is LoggedInUser) {
      userRepository.disconnect(loginState.uid, userID);
    }
  }

  static _approveAccount(
    FirestoreUserRepository userRepository,
    String userID,
  ) {
    userRepository.approveAccount(userID);
  }

  static _upload(
      FirestoreUserRepository userRepository, String userID, File file) {
    userRepository.uploadImage(userID, file);
  }

  static List<FeedItem> _entitiesToFeedItems(
    List<PostEntity> entities,
    String uid,
  ) {
    return entities.map((entity) {
      return FeedItem(
          id: entity.documentId,
          tags: entity.tags,
          timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
          timePostedString:
              timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
          message: entity.postMessage,
          name:
              (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
          userImage: entity.image ?? "",
          isPoll: entity.type == PostType.poll.index,
          postImages: _getPostImages(entity),
          userId: entity.ownerId,
          isLiked: (entity.likes ?? []).contains(uid),
          isMine: entity.ownerId == uid,
          abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
          isShared: entity.isShared ?? false,
          pollData: entity.pollData ?? [],
          likes: entity.likes ?? [],
          sharedPost: entity.sharedPost != null
              ? _entityToSharedItem(entity.sharedPost, uid, [])
              : null,
          type: (entity.postData != null && entity.postData.isNotEmpty)
              ? entity.postData[0].type ?? 0
              : 0);
    }).toList();
  }

  static FeedItem _entityToSharedItem(
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

  static Stream<ProfileState> _toProfileState(
    LoginState loginState,
    String userId,
    FirestoreUserRepository userRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialProfileState.copyWith(
          error: ProfileNotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository
          .getUserById(uid: userId)
          .map((user) {
            var profile = _entityToProfileItem(user, loginState);
            return _kInitialProfileState.copyWith(
                profile: profile,
                isLoading: false,
                isAdmin: loginState.isAdmin);
          })
          .startWith(_kInitialProfileState)
          .onErrorReturnWith((e) {
            return _kInitialProfileState.copyWith(
                error: e, isLoading: false, isAdmin: loginState.isAdmin);
          });
    }

    return Stream.value(
      _kInitialProfileState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static Stream<RecentFeedState> _toFeedState(
    LoginState loginState,
    String userId,
    FirestorePostRepository postRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialRecentFeedState.copyWith(
          error: ProfileNotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return postRepository
          .postsByOwner(uid: userId)
          .map((posts) {
            return _kInitialRecentFeedState.copyWith(
              feedItems: _entitiesToFeedItems(posts, loginState.uid),
              isLoading: false,
            );
          })
          .startWith(_kInitialRecentFeedState)
          .onErrorReturnWith((e) {
            return _kInitialRecentFeedState.copyWith(
              error: e,
              isLoading: false,
            );
          });
    }

    return Stream.value(
      _kInitialRecentFeedState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static ProfileItem _entityToProfileItem(
    UserEntity entity,
    LoginState loginState,
  ) {
    return ProfileItem(
        id: entity.documentId,
        uid: entity.uid,
        photo: entity.image ?? "",
        isChurch: entity.isChurch ?? false,
        isVerified: entity.isVerified ?? false,
        fullName: entity.fullName,
        churchName: entity.churchName ?? "NONE",
        connections: entity.connections ?? [],
        shares: entity.shares ?? [],
        trophies: entity.treeTrophies,
        type: entity.type,
        churchDenomination: entity.churchDenomination ?? 'NONE',
        churchAddress: entity.churchAddress ?? 'NONE',
        aboutMe: entity.aboutMe ?? 'Hey I am new to Tree',
        title: entity.title ?? 'NONE',
        city: entity.city ?? 'NONE',
        relationStatus: entity.relationStatus ?? 'NONE',
        churchInfo: entity.churchInfo,
        isChurchUpdated: entity.isChurchUpdated ?? false,
        isProfileUpdated: entity.isProfileUpdated ?? false,

        //Variables
        myProfile:
            entity.uid == (loginState is LoggedInUser ? loginState.uid : ""),
        isFriend: (loginState is LoggedInUser) &&
            entity.uid != loginState.uid &&
            (entity.connections ?? []).contains(loginState.uid),
        sent: (loginState is LoggedInUser) &&
            entity.uid != loginState.uid &&
            (entity.receivedRequests ?? []).contains(loginState.uid),
        received: (loginState is LoggedInUser) &&
            entity.uid != loginState.uid &&
            (entity.sentRequests ?? []).contains(loginState.uid));
  }

  static Stream<ProfileState> _getProfile(
    UserBloc userBloc,
    String userId,
    FirestoreUserRepository userRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toProfileState(loginState, userId, userRepository);
    });
  }

  static Stream<RecentFeedState> _getRecentFeed(
    UserBloc userBloc,
    String userId,
    FirestorePostRepository postRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toFeedState(loginState, userId, postRepository);
    });
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

  static Stream<FeedItemLikeMessage> saveLikeOrUnlike(
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

  static void _suspendUser(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
    String userId,
  ) {
    print('[DEBUG] ProfileBloc#suspendUser');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser && loginState.isAdmin) {
      userRepository.suspendUser(userId);
    }
  }

  static void _deleteUser(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
    String userId,
  ) {
    print('[DEBUG] ProfileBloc#deleteUser');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser && loginState.isAdmin) {
      userRepository.deleteUser(userId);
    }
  }

  static Stream<FeedUnconnectMessage> performUnconnect(
    FirestoreUserRepository userRepository,
    String userId,
    String userToUnfollow,
  ) async* {
    print('[DEBUG] ProfileBloc#performUnconnect');
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
    print('[DEBUG] ProfileBloc#sharePost');
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
    print('[DEBUG] ProfileBloc#answerPoll');
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
