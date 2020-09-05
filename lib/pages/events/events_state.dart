import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Enum
///
enum EventOption { report, edit, delete, changeStatus, updateReach }
enum EventFilter { none, pending, inactive, completed }

///
/// Message
///
@immutable
abstract class EventsMessage {}

///
/// Error
///
@immutable
abstract class EventsError {}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class EventsListState extends Equatable {
  final List<EventItem> eventItems;
  final List<EventItem> myEvents;
  final bool isLoading;
  final Object error;

  const EventsListState({
    @required this.eventItems,
    @required this.myEvents,
    @required this.isLoading,
    @required this.error,
  });

  EventsListState copyWith({eventItems, myEvents, isLoading, error}) {
    return EventsListState(
      eventItems: eventItems ?? this.eventItems,
      myEvents: myEvents ?? this.myEvents,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [eventItems, myEvents, isLoading, error];

  @override
  bool get stringify => true;
}

@immutable
class EventItem extends Equatable {
  final String id;
  final String title;
  final String details;
  final String ownerId;
  final String image;
  final String location;
  final bool isSponsored;
  final int eventType;
  final DateTime startDate;
  final List<String> isAttending;
  final bool isMine;
  final bool isAdmin;

  const EventItem({
    @required this.id,
    @required this.title,
    @required this.details,
    @required this.ownerId,
    @required this.image,
    @required this.location,
    @required this.isSponsored,
    @required this.eventType,
    @required this.startDate,
    @required this.isAttending,
    @required this.isMine,
    @required this.isAdmin,
  });

  @override
  List get props => [
        id,
        title,
        details,
        ownerId,
        image,
        location,
        isSponsored,
        eventType,
        startDate,
        isAttending,
        isMine,
        isAdmin,
      ];

  @override
  bool get stringify => true;
}
