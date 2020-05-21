import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/post_entity.dart';
import './feed_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;

const _kInitialFeedListState = FeedListState(
  error: null,
  isLoading: true,
  feedItems: []
);

class FeedBloc implements BaseBloc {
  ///
  /// Input functions
  ///


  ///
  /// Output streams
  ///
  final ValueStream<FeedListState> feedListState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  FeedBloc._({
    @required this.feedListState$,
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


    ///
    /// Streams
    ///
    final feedListState$ = _getFeedList(
        userBloc,
        postRepository,
      ).publishValueSeeded(_kInitialFeedListState);

    final subscriptions = <StreamSubscription>[
      feedListState$.connect()
    ];

    return FeedBloc._(
      feedListState$: feedListState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
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
      return Rx.zip2(
          postRepository.getByAdmin(),
          postRepository.postsByUser(uid: loginState.uid),
          (byAdmin, userFeed) {
            var feed = _entitiesToFeedItems(byAdmin);
            var userPosts = _entitiesToFeedItems(userFeed);

            feed.addAll(userPosts);
            feed.sort((a, b) => b.timePosted.compareTo(a.timePosted));

            return _kInitialFeedListState.copyWith(
              isLoading: false,
              feedItems: feed,
            );
          }
        )
        .startWith(_kInitialFeedListState)
        .onErrorReturnWith((e) {
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
}