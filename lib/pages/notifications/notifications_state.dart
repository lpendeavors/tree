import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
@immutable
abstract class NotificationsMessage {}

///
/// Error
///
@immutable
abstract class NotificationsError {}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class NotificationsListState extends Equatable {
  final List<NotificationItem> notificationItems;
  final bool isLoading;
  final Object error;

  const NotificationsListState({
    this.isLoading,
    this.error,
    this.notificationItems,
  });

  NotificationsListState copyWith({notificationItems, isLoading, error}) {
    return NotificationsListState(
      notificationItems: notificationItems ?? this.notificationItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [notificationItems, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class NotificationItem extends Equatable {
  final String id;

  const NotificationItem({
    this.id,
  });

  @override
  List get props => [id];

  @override
  bool get stringify => true;
}