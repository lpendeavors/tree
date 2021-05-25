import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/data/post/firestore_post_repository.dart';
import 'package:treeapp/models/old/poll_data.dart';
import 'package:treeapp/models/old/post_entity.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './poll_responders_state.dart';

const _kInitialPollRespondersState = PollRespondersState(
  responders: [],
  isLoading: true,
  error: null,
);

class PollRespondersBloc extends BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final ValueStream<PollRespondersState> pollRespondersState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  PollRespondersBloc._({
    @required this.pollRespondersState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory PollRespondersBloc({
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
    @required FirestorePostRepository postRepository,
    @required List<String> responderIds,
    @required String pollId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(responderIds != null, 'responseIds cannot be null');
    assert(pollId != null, 'pollIds cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final pollRespondersState$ = _getResponders(
      pollId,
      responderIds,
      userBloc,
      userRepository,
      postRepository,
    ).publishValueSeeded(_kInitialPollRespondersState);

    final subscriptions = <StreamSubscription>[
      pollRespondersState$.connect(),
    ];

    final controllers = <StreamController>[];

    return PollRespondersBloc._(
        pollRespondersState$: pollRespondersState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<PollRespondersState> _toState(
    String pollId,
    List<String> responderIds,
    LoginState loginState,
    FirestoreUserRepository userRepository,
    FirestorePostRepository postRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialPollRespondersState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.combineLatest2(userRepository.getMyConnections(responderIds),
          postRepository.postById(postId: pollId), (responders, poll) {
        return _kInitialPollRespondersState.copyWith(
          responders: _entitiesToResponderItems(responders, poll),
          isLoading: false,
        );
      }).startWith(_kInitialPollRespondersState).onErrorReturnWith((e) {
        return _kInitialPollRespondersState.copyWith(
          isLoading: false,
          error: e,
        );
      });
    }

    return Stream.value(
      _kInitialPollRespondersState.copyWith(
        isLoading: false,
        error: 'Dont know loginState=$loginState',
      ),
    );
  }

  static List<ResponderItem> _entitiesToResponderItems(
    List<UserEntity> responders,
    PostEntity post,
  ) {
    return responders.map((entity) {
      return ResponderItem(
        id: entity.id,
        name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
        image: entity.image ?? '',
        answer: _getAnswer(entity.id, post.pollData),
      );
    }).toList();
  }

  static Stream<PollRespondersState> _getResponders(
    String pollId,
    List<String> responderIds,
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
    FirestorePostRepository postRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        pollId,
        responderIds,
        loginState,
        userRepository,
        postRepository,
      );
    });
  }

  static String _getAnswer(String userId, List<PollData> pollData) {
    var answer = '';

    pollData.forEach((p) {
      if (p.answerResponse.contains(userId)) {
        answer = p.answerTitle;
      }
    });

    return answer;
  }
}
