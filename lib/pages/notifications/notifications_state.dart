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
  final String image;
  final String time;
  final bool isNew;
  final String sharedBy;
  final String body;

  const NotificationItem({
    this.id,
    this.time,
    this.image,
    this.isNew,
    this.sharedBy,
    this.body,
  });

  @override
  List get props => [
    id,
    body,
    sharedBy,
    image,
    time,
    isNew,
  ];

  @override
  bool get stringify => true;
}