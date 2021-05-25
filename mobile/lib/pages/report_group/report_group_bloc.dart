import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/report/firestore_report_repository.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import './report_group_state.dart';

bool _isMessageValid(String message) {
  return message.length > 0;
}

class ReportGroupBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() saveReport;
  final void Function(String) messageChanged;

  ///
  /// Output streams
  ///
  final Stream<ReportGroupMessage> message$;
  final Stream<ReportMessageError> messageError$;
  final ValueStream<bool> isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ReportGroupBloc._({
    @required this.saveReport,
    @required this.messageChanged,
    @required this.messageError$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => dispose;

  factory ReportGroupBloc({
    @required String userId,
    @required String groupId,
    @required UserBloc userBloc,
    @required FirestoreReportRepository reportRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userId != null, 'userId cannot be null');
    assert(groupId != null, 'groupId cannot be null');
    assert(userBloc != null, 'userBloc cannot be null');
    assert(reportRepository != null, 'reportRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final messageSubject = BehaviorSubject<String>.seeded('');
    final saveReportSubject = PublishSubject<void>();

    ///
    /// Streams
    ///
    final messageError$ = messageSubject.map((message) {
      if (_isMessageValid(message)) return null;
      return const ReportMessageError();
    }).share();

    final allFieldsAreValid$ = Rx.combineLatest(
      [
        messageError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = saveReportSubject
        .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
        .where((isValid) => isValid)
        .exhaustMap(
          (_) => performSave(
            groupId,
            userId,
            userBloc,
            reportRepository,
            messageSubject.value,
            isLoadingSubject,
          ),
        )
        .publish();

    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      message$.connect(),
    ];

    final controllers = <StreamController>[
      messageSubject,
      isLoadingSubject,
    ];

    return ReportGroupBloc._(
        saveReport: () => saveReportSubject.add(null),
        messageChanged: messageSubject.add,
        messageError$: messageError$,
        message$: message$,
        isLoading$: isLoadingSubject,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  static Stream<ReportGroupMessage> performSave(
    String roomId,
    String userId,
    UserBloc userBloc,
    FirestoreReportRepository reportRepository,
    String message,
    Sink<bool> isLoading,
  ) async* {
    print('[DEBUG] ReportPostBloc#performSave');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoading.add(true);
        await reportRepository.save(
          loginState.uid,
          loginState.email,
          loginState.fullName,
          loginState.image,
          loginState.token,
          loginState.isAdmin,
          loginState.isVerified,
          loginState.isChurch,
          null,
          message,
          userId,
          1,
          roomId,
        );
        yield ReportGroupSuccess();
      } catch (e) {
        yield ReportGroupError(e);
      } finally {
        isLoading.add(false);
      }
    }

    yield ReportGroupError(NotLoggedInError());
  }
}
