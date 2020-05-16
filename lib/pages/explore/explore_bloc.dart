import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/post_entity.dart';
import '../../models/old/user_entity.dart';
import './explore_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialExploreState = ExploreState(
  error: null,
  isLoading: true,
  connectionItems: [],
  postItems: [],
);

class ExploreBloc implements BaseBloc {
  ///
  /// Input functions
  ///


  ///
  /// Output streams
  ///
  final ValueStream<ExploreState> exploreState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ExploreBloc._({
    @required this.exploreState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ExploreBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controllers
    ///


    ///
    /// Streams
    ///
    final exploreState$ = _getExploreList(
      userBloc,
      postRepository,
      userRepository,
    ).publishValueSeeded(_kInitialExploreState);

    final subscriptions = <StreamSubscription>[
      exploreState$.connect(),
    ];

    return ExploreBloc._(
      exploreState$: exploreState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<ExploreState> _toState(
    LoginState loginState,
    FirestoreUserRepository userRepository,
    FirestorePostRepository postRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialExploreState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(
        userRepository.getSuggestions(),
        postRepository.postsForCollage(),
        (users, posts) {
          return _kInitialExploreState.copyWith(
            connectionItems: _userEntitiesToItems(users),
            postItems: _postEntitiesToItems(posts),
            isLoading: false,
          );
        }
      ).startWith(_kInitialExploreState)
      .onErrorReturnWith((e) {
        return _kInitialExploreState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialExploreState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<ConnectionItem> _userEntitiesToItems(
    List<UserEntity> entities,
  ) {
    return entities.map((entity) {
      return ConnectionItem(
        id: entity.id,
        fullName: '${entity.firstName} ${entity.lastName}',
        location: "",
        church: "",
        isChurch: entity.isChurch,
      );
    }).toList();
  }

  static List<PostItem> _postEntitiesToItems(
    List<PostEntity> entities,
  ) {
    return entities.map((entity) {
      return PostItem(
        id: entity.documentId,
        image: entity.image,
      );
    }).toList();
  }

  static Stream<ExploreState> _getExploreList(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    FirestoreUserRepository userRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        userRepository,
        postRepository
      );
    });
  }
}