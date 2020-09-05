import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/notification/firestore_notification_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/notification_entity.dart';
import './notifications_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;

const _kInitialNotificationsListState = NotificationsListState(
  error: null,
  isLoading: true,
  notificationItems: [],
);

class NotificationsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function(List<String>) markRead;

  ///
  /// Output streams
  ///
  final ValueStream<NotificationsListState> notificationsListState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  NotificationsBloc._({
    @required this.markRead,
    @required this.notificationsListState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory NotificationsBloc({
    @required UserBloc userBloc,
    @required FirestoreNotificationRepository notificationRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(notificationRepository != null,
        'notificationRepository cannot be null');

    ///
    /// Stream controllers
    ///

    ///
    /// Streams
    ///
    final notificationsListState$ = _getNotificationList(
      userBloc,
      notificationRepository,
    ).publishValueSeeded(_kInitialNotificationsListState);

    final subscriptions = <StreamSubscription>[
      notificationsListState$.connect(),
    ];

    return NotificationsBloc._(
        notificationsListState$: notificationsListState$,
        markRead: (notifications) => _markNotificationsRead(
              notificationRepository,
              notifications,
              userBloc,
            ),
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  void dispose() => _dispose;

  static Stream<NotificationsListState> _toState(
    LoginState loginState,
    FirestoreNotificationRepository notificationRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialNotificationsListState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return notificationRepository
          .getByOwner(loginState.uid)
          .map((entities) {
            return _entitiesToNotificationItems(entities);
          })
          .map((notificationItems) {
            return _kInitialNotificationsListState.copyWith(
              notificationItems: notificationItems,
              isLoading: false,
            );
          })
          .startWith(_kInitialNotificationsListState)
          .onErrorReturnWith((e) {
            return _kInitialNotificationsListState.copyWith(
              error: e,
              isLoading: false,
            );
          });
    }

    return Stream.value(
      _kInitialNotificationsListState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<NotificationItem> _entitiesToNotificationItems(
    List<NotificationEntity> entities,
  ) {
    return entities.map((entity) {
      return NotificationItem(
        id: entity.id,
        body: entity.body,
        time: timeago.format(entity.createdAt.toDate()),
        sharedBy: entity.fullName,
        isNew: (entity.readBy ?? []).contains(entity.id),
        image: entity.image,
        user: entity.id,
        navigateToId: entity.postId,
      );
    }).toList();
  }

  static Stream<NotificationsListState> _getNotificationList(
    UserBloc userBloc,
    FirestoreNotificationRepository notificationRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(loginState, notificationRepository);
    });
  }

  static void _markNotificationsRead(
    FirestoreNotificationRepository notificationRepository,
    List<String> notifications,
    UserBloc userBloc,
  ) {
    var loginState = userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      notificationRepository.markRead(notifications, loginState.uid);
    }
  }
}
