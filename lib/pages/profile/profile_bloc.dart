import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
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
  feedItems: [],
  isAdmin: false,
);

const _kInitialRecentFeedState = RecentFeedState(
    feedItems: [],
    isLoading: true,
    error: false
);


class ProfileBloc implements BaseBloc {
  ///
  /// Input functions
  /// 
  final void Function() sendConnectRequest;
  final void Function() cancelConnectRequest;
  final void Function() acceptConnectRequest;
  final void Function() disconnect;
  final void Function() approveAccount;
  final void Function(File file) setPhoto;

  ///
  /// Output streams
  /// 
  final ValueStream<ProfileState> profileState$;
  final ValueStream<RecentFeedState> recentFeedState$;

  ///
  /// Clean up
  /// 
  final void Function() _dispose;

  ProfileBloc._({
    @required this.profileState$,
    @required this.recentFeedState$,
    @required this.sendConnectRequest,
    @required this.cancelConnectRequest,
    @required this.acceptConnectRequest,
    @required this.disconnect,
    @required this.approveAccount,
    @required this.setPhoto,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ProfileBloc({
    @required UserBloc userBloc,
    @required String userId,
    @required FirestoreUserRepository userRepository,
    @required FirestorePostRepository postRepository,
  }) {
    ///
    /// Assert
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');

    ///
    /// Controllers
    /// 
    final sendConnectRequestController = PublishSubject<void>();
    final cancelConnectRequestController = PublishSubject<void>();
    final acceptConnectRequestController = PublishSubject<void>();
    final disconnectController = PublishSubject<void>();
    final approveController = PublishSubject<void>();
    final setPhotoController = BehaviorSubject<File>();

    final sendConnectRequest$ = sendConnectRequestController.exhaustMap((_) => _sendConnectRequest(userRepository, userId, userBloc.loginState$.value)).publish();
    final cancelConnectRequest$ = cancelConnectRequestController.exhaustMap((_) => _cancelConnectRequest(userRepository, userId, userBloc.loginState$.value)).publish();
    final acceptConnectRequest$ = acceptConnectRequestController.exhaustMap((_) => _acceptConnectRequest(userRepository, userId, userBloc.loginState$.value)).publish();
    final disconnect$ = disconnectController.exhaustMap((_) => _disconnect(userRepository, userId, userBloc.loginState$.value)).publish();
    final approveAccount$ = approveController.exhaustMap((_) => _approveAccount(userRepository, userId)).publish();
    final photo$ = setPhotoController.exhaustMap((_) => _upload(userRepository, userId, setPhotoController.value)).publish();

    /// 
    /// Streams
    /// 
    final profileState$ = _getProfile(
      userBloc,
      userId,
      userRepository,
      postRepository,
    ).publishValueSeeded(_kInitialProfileState);

    final recentFeedState$ = _getRecentFeed(
        userBloc,
        userId,
        postRepository
    ).publishValueSeeded(_kInitialRecentFeedState);

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
    ];

    final controllers = <StreamController>[
      sendConnectRequestController,
      cancelConnectRequestController,
      acceptConnectRequestController,
      disconnectController,
      approveController,
      setPhotoController,
    ];

    return ProfileBloc._(
      profileState$: profileState$,
      recentFeedState$: recentFeedState$,
      sendConnectRequest: () => sendConnectRequestController.add(null),
      cancelConnectRequest: () => cancelConnectRequestController.add(null),
      acceptConnectRequest: () => acceptConnectRequestController.add(null),
      disconnect: () => disconnectController.add(null),
      approveAccount: () => approveController.add(null),
      setPhoto: (file) => setPhotoController.add(file),
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static _sendConnectRequest(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if(loginState is LoggedInUser){
      userRepository.sendConnectionRequest(loginState.uid, userID);
    }
  }

  static _cancelConnectRequest(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if(loginState is LoggedInUser){
      userRepository.cancelConnectionRequest(loginState.uid, userID);
    }
  }

  static _acceptConnectRequest(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if(loginState is LoggedInUser){
      userRepository.acceptConnectionRequest(userID, loginState.uid);
    }
  }

  static _disconnect(
    FirestoreUserRepository userRepository,
    String userID,
    LoginState loginState,
  ) {
    if(loginState is LoggedInUser){
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
    FirestoreUserRepository userRepository,
    String userID,
    File file
  ) {
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
        timePostedString: timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
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
    }).toList();
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

  static Stream<ProfileState> _toProfileState(
    LoginState loginState,
    String userId,
    FirestoreUserRepository userRepository,
    FirestorePostRepository postRepository,
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
      return Rx.zip2(
        userRepository.getUserById(uid: userId),
        postRepository.postsByOwner(uid: userId),
        (user, posts){
          return _kInitialProfileState.copyWith(
            isLoading: false,
            feedItems: _entitiesToFeedItems(posts, loginState.uid),
            profile: _entityToProfileItem(user, loginState),
          );
        })
        .startWith(_kInitialProfileState)
        .onErrorReturnWith((e) {
          return _kInitialProfileState.copyWith(
            error: e,
            isLoading: false,
          );
        }
      )
      .startWith(_kInitialProfileState)
      .onErrorReturnWith((e) {
        return _kInitialProfileState.copyWith(
          error: e,
          isLoading: false,
          isAdmin: loginState.isAdmin
        );
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
      return postRepository.postsByOwner(uid: userId)
      .map((posts){
        var userPosts = _entitiesToFeedItems(posts, loginState.uid);
        return _kInitialRecentFeedState.copyWith(
            feedItems: userPosts,
            isLoading: false
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

      //Variables
      myProfile: entity.uid == (loginState is LoggedInUser ? loginState.uid : ""),
      isFriend: (loginState is LoggedInUser) && entity.uid != loginState.uid && (entity.connections ?? []).contains(loginState.uid),
      sent: (loginState is LoggedInUser) && entity.uid != loginState.uid && (entity.receivedRequests ?? []).contains(loginState.uid),
      received: (loginState is LoggedInUser) && entity.uid != loginState.uid && (entity.sentRequests ?? []).contains(loginState.uid)
    );
  }

  static Stream<ProfileState> _getProfile(
    UserBloc userBloc,
    String userId,
    FirestoreUserRepository userRepository,
    FirestorePostRepository postRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toProfileState(
        loginState,
        userId,
        userRepository,
        postRepository,
      );
    });
  }

  static Stream<RecentFeedState> _getRecentFeed(
      UserBloc userBloc,
      String userId,
      FirestorePostRepository postRepository,
      ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toFeedState(
          loginState,
          userId,
          postRepository
      );
    });
  }
}