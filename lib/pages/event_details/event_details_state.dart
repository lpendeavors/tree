import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class EventDetailsMessage {
  const EventDetailsMessage();
}

abstract class EventAttendeesMessage {
  const EventAttendeesMessage();
}

class EventAttendanceChangedSuccess implements EventAttendeesMessage {
  const EventAttendanceChangedSuccess();
}

class EventAttendanceChangedError implements EventAttendeesMessage {
  final Object error;
  const EventAttendanceChangedError(this.error);
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class EventDetailsState extends Equatable {
  final EventDetailItem eventDetails;
  final bool isLoading;
  final Object error;

  const EventDetailsState({
    @required this.eventDetails,
    @required this.isLoading,
    @required this.error,
  });

  EventDetailsState copyWith({eventDetails, isLoading, error}) {
    return EventDetailsState(
      eventDetails: eventDetails ?? this.eventDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    eventDetails,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}

@immutable
class EventDetailItem extends Equatable {
  final String id;
  final String title;
  final String image;
  final List<String> attendees;
  final bool isAttending;
  final bool isSponsored;
  final bool isRejected;
  final bool isMine;
  final String reason;
  final String webAddress;
  final int status;
  final double longitude;
  final double latitude;
  final int type;
  final String location;
  final double price;
  final String details;

  const EventDetailItem({
    @required this.id,
    @required this.title,
    @required this.image,
    @required this.attendees,
    @required this.isSponsored,
    @required this.isMine,
    @required this.isRejected,
    @required this.reason,
    @required this.status,
    @required this.webAddress,
    @required this.isAttending,
    @required this.latitude,
    @required this.longitude,
    @required this.type,
    @required this.location,
    @required this.price,
    @required this.details,
  });

  @override
  List get props => [
    id,
    title,
    image,
    attendees,
    isSponsored,
    isMine,
    isRejected,
    reason,
    status,
    webAddress,
    isAttending,
    latitude,
    longitude,
    type,
    location,
    price,
    details,
  ];

  @override
  bool get stringify => true;
}