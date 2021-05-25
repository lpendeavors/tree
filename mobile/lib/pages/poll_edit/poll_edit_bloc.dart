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
  final void Function(int) typeChanged;
  final void Function(List<Map<String, String>>) taggedChanged;
  final void Function(List<PollAnswerItem>) answersChanged;
  final void Function(int) correctAnswerChanged;
  final void Function(DateTime) endDateChanged;
  final void Function(String) questionChanged;
  final void Function() savePoll;

  ///
  /// Output streams
  ///
  final ValueStream<String> question$;
  final ValueStream<int> type$;
  final ValueStream<List<Map<String, String>>> tagged$;
  final ValueStream<List<PollAnswerItem>> answers$;
  final ValueStream<int> correctAnswer$;
  final ValueStream<DateTime> endDate$;
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
    @required this.questionChanged,
    @required this.typeChanged,
    @required this.taggedChanged,
    @required this.answersChanged,
    @required this.correctAnswerChanged,
    @required this.endDateChanged,
    @required this.question$,
    @required this.type$,
    @required this.tagged$,
    @required this.answers$,
    @required this.correctAnswer$,
    @required this.endDate$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory EditPollBloc({
    String pollId,
    String groupId,
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
    final questionSubject = BehaviorSubject<String>.seeded('');
    final typeSubject = BehaviorSubject<int>.seeded(0);
    final answersSubject = BehaviorSubject<List<PollAnswerItem>>.seeded([]);
    final correctAnswerSubject = BehaviorSubject<int>.seeded(0);
    final taggedSubject = BehaviorSubject<List<Map<String, String>>>.seeded([]);
    final endDateSubject = BehaviorSubject<DateTime>.seeded(null);
    final savePollSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final message$ = savePollSubject
        .switchMap(
          (_) => performSave(
            pollId,
            groupId,
            userBloc,
            postRepository,
            questionSubject.value,
            answersSubject.value,
            correctAnswerSubject.value,
            typeSubject.value,
            endDateSubject.value,
            taggedSubject.value.map((t) => t["id"]).toList(),
            isLoadingSubject,
          ),
        )
        .publish();

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
      typeSubject,
      taggedSubject,
      answersSubject,
      correctAnswerSubject,
      endDateSubject,
      isLoadingSubject,
    ];

    return EditPollBloc._(
        savePoll: () => savePollSubject.add(null),
        questionChanged: questionSubject.add,
        typeChanged: typeSubject.add,
        taggedChanged: taggedSubject.add,
        answersChanged: answersSubject.add,
        correctAnswerChanged: correctAnswerSubject.add,
        endDateChanged: endDateSubject.add,
        question$: questionSubject.stream,
        type$: typeSubject.stream,
        tagged$: taggedSubject.stream,
        answers$: answersSubject.stream,
        correctAnswer$: correctAnswerSubject.stream,
        endDate$: endDateSubject.stream,
        isLoading$: isLoadingSubject,
        message$: message$,
        pollEditState$: pollEditState$,
        dispose: () async {
          Future.wait(subscriptions.map((s) => s.cancel()));
          Future.wait(controllers.map((c) => c.close()));
        });
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
        return postRepository
            .postById(postId: pollId)
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

  static FeedPollItem _entityToPollItem(PostEntity entity) {
    return FeedPollItem(
      id: entity.documentId,
      type: entity.type,
      answers: entity.pollData.map((data) {
        var item = PollAnswerItem();
        item.label = data.label;
        item.answer = data.answerTitle;
        item.isCorrect = item.isCorrect;
        return item;
      }).toList(),
      question: entity.postMessage,
      endDate: DateTime.fromMillisecondsSinceEpoch(entity.pollDuration[1]),
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
    String groupId,
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    String question,
    List<PollAnswerItem> answers,
    int correctAnswer,
    int pollType,
    DateTime endDate,
    List<String> tagged,
    Sink<bool> isLoadingSubject,
  ) async* {
    print('[DEBUG] EditPollBloc#performSave');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        var pollAnswers = answers.map((a) {
          return <String, dynamic>{
            'answerTitle': a.answer.toString(),
            'answerPosition': -1,
            'label': a.label,
            'isAnswer': answers.indexOf(a) == correctAnswer,
            'answerResponse': List<String>(),
          };
        }).toList();

        await postRepository.savePoll(
          pollId,
          groupId,
          loginState.isAdmin,
          loginState.uid,
          loginState.fullName,
          loginState.image,
          loginState.token,
          loginState.isVerified,
          groupId != null,
          false,
          pollType == 1,
          loginState.isVerified,
          loginState.connections,
          pollAnswers,
          endDate,
          question,
          tagged,
          pollType,
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
