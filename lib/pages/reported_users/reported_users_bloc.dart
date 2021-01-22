import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:treeapp/models/old/comment_entity.dart';
import 'package:treeapp/models/old/group_entity.dart';
import 'package:treeapp/pages/chat/chat_tabs_state.dart';
import 'package:treeapp/pages/comments/comments_state.dart';
import 'package:treeapp/pages/feed/feed_state.dart';
import 'package:tuple/tuple.dart';
import '../../util/post_utils.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/report/firestore_report_repository.dart';
import '../../models/old/report_entity.dart';
import '../../models/old/post_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './reported_users_state.dart';
import './reported_users_bloc.dart';

const _kInitialReportedUsersState = ReportedUsersState(
  reports: [],
  isLoading: true,
  error: null,
);

class ReportedUsersBloc extends BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final ValueStream<ReportedUsersState> reportedUsersState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ReportedUsersBloc._({
    @required this.reportedUsersState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ReportedUsersBloc({
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

    ///
    /// Streams
    ///
    final reportedUsersState$ = _getReportedUsers(
      userBloc,
      reportRepository,
    ).publishValueSeeded(_kInitialReportedUsersState);

    final subscriptions = <StreamSubscription>[
      reportedUsersState$.connect(),
    ];

    return ReportedUsersBloc._(
        reportedUsersState$: reportedUsersState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<ReportedUsersState> _toState(
    LoginState loginState,
    FirestoreReportRepository reportRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialReportedUsersState.copyWith(
          error: 'NotLoggedInError()',
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return reportRepository
          .get()
          .map((entities) {
            var reportItems = _entitiesToReportItems(entities);

            return _kInitialReportedUsersState.copyWith(
              isLoading: false,
              reports: reportItems,
            );
          })
          .startWith(_kInitialReportedUsersState)
          .onErrorReturnWith((e) {
            return _kInitialReportedUsersState.copyWith(
              error: e,
              isLoading: false,
            );
          });
    }

    return Stream.value(
      _kInitialReportedUsersState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<ReportItem> _entitiesToReportItems(
    List<ReportEntity> entities,
  ) {
    return entities.map((e) {
      return ReportItem(
        id: e.id,
        group: e.groupId,
        post: e.reportPost != null
            ? e.reportPost.docId
            : e.postId != null
                ? e.postId
                : null,
        comment: e.commentId,
        userImage: e.image,
        userName: (e.isChurch ?? false) ? e.churchName : e.fullName,
        userId: e.uid,
        message: e.reportReason,
        user: e.reportType == 2 ? e.userId : null,
      );
    }).toList();
  }

  static Stream<ReportedUsersState> _getReportedUsers(
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
