import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
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
  error: false,
  feedItems: []
);

class ProfileBloc implements BaseBloc {
  ///
  /// Input functions
  /// 
  

  ///
  /// Output streams
  /// 
  final ValueStream<ProfileState> profileState$;

  ///
  /// Clean up
  /// 
  final void Function() _dispose;

  ProfileBloc._({
    @required this.profileState$,
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
    /// Stream controllers
    /// 
    

    /// 
    /// Streams
    /// 
    final profileState$ = _getProfile(
      userBloc,
      userId,
      userRepository,
      postRepository
    ).publishValueSeeded(_kInitialProfileState);

    final subscriptions = <StreamSubscription>[
      profileState$.connect(),
    ];

    return ProfileBloc._(
      profileState$: profileState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static List<FeedItem> _entitiesToFeedItems(
      List<PostEntity> entities,
      ) {
    return entities.map((entity) {
      return FeedItem(
        id: entity.documentId,
        tags: entity.tags,
        timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        timePostedString: timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
        message: entity.postMessage,
        name: entity.fullName != null ? entity.fullName : entity.churchName,
        userImage: entity.image,
        isPoll: entity.type == PostType.poll.index,
        postImages: _getPostImages(entity),
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

  static Stream<ProfileState> _toState(
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
        userRepository.getUserById(uid: userId ?? '02zZ20juDYfvWCHWwYzGgrOPvAr2'),//loginState.uid),
        postRepository.postsByOwner(uid: userId ?? '02zZ20juDYfvWCHWwYzGgrOPvAr2'),//loginState.uid),
        (user, posts){
          var profile = _entityToProfileItem(user, loginState);
          var userPosts = _entitiesToFeedItems(posts);

      return userRepository.getUserById(uid: userId)
        .map((entity) {
          return _entityToProfileItem(
            entity,
            loginState,
          );
        })
        .map((profileItem) {
          return _kInitialProfileState.copyWith(
            profile: profileItem,
            isLoading: false,
          );
        })
        .startWith(_kInitialProfileState)
        .onErrorReturnWith((e) {
          return _kInitialProfileState.copyWith(
            feedItems: userPosts,
            profile: profile,
            isLoading: false,
          );
        }
      )
      .startWith(_kInitialProfileState)
      .onErrorReturnWith((e) {
        return _kInitialProfileState.copyWith(
          error: e,
          isLoading: false,
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
      aboutMe: entity.aboutMe 'Hey I am new to Tree',
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
      return _toState(
        loginState,
        userId,
        userRepository,
        postRepository
      );
    });
  }
}