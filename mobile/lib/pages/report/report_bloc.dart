import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/report/firestore_report_repository.dart';
import '../../models/old/report_entity.dart';
import '../../bloc/bloc_provider.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './report_state.dart';

const _kInitialReportState = ReportState(
  isLoading: true,
  error: null,
  reported: [],
);

class ReportBloc implements BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final ValueStream<ReportState> reportState$;
  // final Stream<ReportMessage> message$;
  final ValueStream<bool> isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ReportBloc._({
    @required this.reportState$,
    // @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ReportBloc({
    @required UserBloc userBloc,
    @required FirestoreReportRepository reportRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(reportRepository != null, 'reportRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final reportState$ = _getReported(
      userBloc,
      reportRepository,
    ).publishValueSeeded(_kInitialReportState);

    final subscriptions = <StreamSubscription>[
      reportState$.connect(),
      // message$.connect(),
    ];

    return ReportBloc._(
        reportState$: reportState$,
        isLoading$: isLoadingSubject,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<ReportState> _toState(
    LoginState loginState,
    FirestoreReportRepository reportRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialReportState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return reportRepository
          .get()
          .map((entities) {
            return _entitiesToReportItems(entities);
          })
          .map((reportItems) {
            return _kInitialReportState.copyWith(
              reported: reportItems,
              isLoading: false,
            );
          })
          .startWith(_kInitialReportState)
          .onErrorReturnWith((e) {
            return _kInitialReportState.copyWith(
              isLoading: false,
              error: e,
            );
          });
    }

    return Stream.value(
      _kInitialReportState.copyWith(
        isLoading: false,
        error: 'Dont know loginState=$loginState',
      ),
    );
  }

  static List<ReportItem> _entitiesToReportItems(
    List<ReportEntity> entities,
  ) {
    return entities.map((entity) {
      return ReportItem(
        id: entity.id,
      );
    });
  }

  static Stream<ReportState> _getReported(
    UserBloc userBloc,
    FirestoreReportRepository reportRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        reportRepository,
      );
    });
  }
}
