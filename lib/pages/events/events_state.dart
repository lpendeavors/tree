import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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
    this.eventItems,
    this.myEvents,
    this.isLoading,
    this.error,
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

  const EventItem({
    this.id,
    this.title,
    this.details,
    this.ownerId,
    this.image,
    this.location,
    this.isSponsored,
    this.eventType,
    this.startDate,
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
  ];

  @override
  bool get stringify => true;
}