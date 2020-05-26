import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../models/old/post_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './poll_edit_state.dart';

const _kInitialPollEditState = EditPollState(
  error: null,
  pollItem: null,
  isLoading: true,
);

class EditPollBloc implements BaseBloc {
  /// 
  /// Input functions
  /// 
  final void Function() savePoll;
  
  /// 
  /// Output streams
  /// 
  final ValueStream<EditPollState> pollEditState$;
  final Stream<PollAddedMessage> message$;
  final ValueStream<bool> isLoading$;

  /// 
  /// Clean up
  ///
  final void Function() _dispose;

  EditPollBloc._({
    @required this.savePoll,
    @required this.pollEditState$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory EditPollBloc({
    String pollId,
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
    final savePollSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    /// 
    /// Streams
    /// 
    final message$ = savePollSubject
      .switchMap((_) => performSave(
        pollId,
        userBloc,
        postRepository,
        isLoadingSubject,
      ),
    ).publish();

    final pollEditState$ = _getPollDetails(
      userBloc,
      postRepository,
      pollId,
    ).publishValueSeeded(_kInitialPollEditState);

    ///
    /// Controllers and subscriptions
    /// 
    final subscriptions = <StreamSubscription>[
      pollEditState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingSubject,
    ];

    return EditPollBloc._(
      savePoll: () => savePollSubject.add(null),
      isLoading$: isLoadingSubject,
      message$: message$,
      pollEditState$: pollEditState$,
      dispose: () async {
        Future.wait(subscriptions.map((s) => s.cancel()));
        Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  static Stream<EditPollState> _toState(
    LoginState loginState,
    FirestorePostRepository postRepository,
    String pollId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialPollEditState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (pollId != null) {
        return postRepository.postById(postId: pollId)
          .map((entity) {
            return _entityToPollItem(entity);
          })
          .map((pollItem) {
            return _kInitialPollEditState.copyWith(
              pollItem: pollItem,
              isLoading: false,
            );
          })
          .startWith(_kInitialPollEditState)
          .onErrorReturnWith((e) {
            return _kInitialPollEditState.copyWith(
              error: e,
              isLoading: false,
            );
          });
      } else {
        return Stream.value(
          _kInitialPollEditState.copyWith(
            isLoading: false,
          ),
        );
      }
    }

    return Stream.value(
      _kInitialPollEditState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static FeedPollItem _entityToPollItem(
    PostEntity entity
  ) {
    return FeedPollItem(
      id: entity.documentId,
    );
  }

  static Stream<EditPollState> _getPollDetails(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    String pollId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        postRepository,
        pollId,
      );
    });
  }

  static Stream<PollAddedMessage> performSave(
    String pollId,
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    Sink<bool> isLoadingSubject,
  ) async* {
    print('[DEBUG] EditPollBloc#performSave');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        postRepository.savePost(
          PostEntity(),
        );
        yield PollAddedMessageSuccess();
      } catch (e) {
        yield PollAddedMessageError(e);
      }
    } else {
      yield PollAddedMessageError(NotLoggedInError());
    }
  }
}