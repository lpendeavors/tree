import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/post_entity.dart';
import './feed_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

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
      return postRepository.posts(uid: loginState.uid)
        .map((entities) {
          return _entitiesToFeedItems(
            entities,
            loginState.uid,
          );
        })
        .map((feedItems) {
          return _kInitialFeedListState.copyWith(
            feedItems: feedItems,
            isLoading: false,
          );
        })
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
    String uid,
  ) {
    return entities.map((entity) {
      return FeedItem(
        id: entity.documentId,
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
}