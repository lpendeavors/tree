import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// 
/// Enums
/// 
enum EventMediaType { other, image, video }

///
/// EditEventMessage
///
@immutable
abstract class EditEventMessage {}

@immutable
abstract class EventDetailsMessage implements EditEventMessage {
  const EventDetailsMessage();
}

@immutable
abstract class EventAddedMessage implements EditEventMessage {}

class EventAddedMessageSuccess implements EventAddedMessage {
  final String eventName;
  const EventAddedMessageSuccess(this.eventName);
}

class EventAddedMessageError implements EventAddedMessage {
  final Object error;
  const EventAddedMessageError(this.error);
}

@immutable
abstract class EventEditedMessage implements EditEventMessage {}

class EventEditedMessageSuccess implements EventEditedMessage {
  final String eventName;
  const EventEditedMessageSuccess(this.eventName);
}

class EventEditedMessageError implements EventEditedMessage {
  final Object error;
  const EventEditedMessageError(this.error);
}

@immutable
abstract class EventError {}

class EventTitleError implements EventError {
  const EventTitleError();
}

class EventDescriptionError implements EventError {
  const EventDescriptionError();
}

class EventStartDateError implements EventError {
  const EventStartDateError();
}

class EventStartTimeError implements EventError {
  const EventStartTimeError();
}

class EventEndDateError implements EventError {
  const EventEndDateError();
}

class EventEndTimeError implements EventError {
  const EventEndTimeError();
}

class EventImageError implements EventError {
  const EventImageError();
}

class EventWebAddressError implements EventError {
  const EventWebAddressError();
}

class EventCostError implements EventError {
  const EventCostError();
}

class EventVenueError implements EventError {
  const EventVenueError();
}

class EventBudgetError implements EventError {
  const EventBudgetError();
}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class EventEditState extends Equatable {
  final EventEditItem eventDetails;
  final bool isLoading;
  final Object error;

  const EventEditState({
    @required this.eventDetails,
    @required this.isLoading,
    @required this.error,
  });

  EventEditState copyWith({eventDetails, isLoading, error}) {
    return EventEditState(
      eventDetails: eventDetails ?? this.eventDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props {
    return [
      eventDetails,
      isLoading,
      error,
    ];
  }

  @override
  bool get stringify => true;
}

@immutable
class EventEditItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime startTime;
  final DateTime endDate;
  final DateTime endTime;
  final double eventCost;
  final String venue;
  final List<EventMediaItem> media;
  final bool isSponsored;
  final double budget;
  final String webAddress;

  const EventEditItem({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.startDate,
    @required this.startTime,
    @required this.endDate,
    @required this.endTime,
    @required this.eventCost,
    @required this.venue,
    @required this.media,
    @required this.isSponsored,
    @required this.budget,
    @required this.webAddress,
  });

  @override
  List<Object> get props => [
    id,
    title,
    description,
    startDate,
    startTime,
    endDate,
    endTime,
    eventCost,
    venue,
    media,
    isSponsored,
    budget,
    webAddress,
  ];

  @override
  bool get stringify => true;
}

@immutable 
class EventMediaItem extends Equatable {
  final EventMediaType type;
  final String url;

  const EventMediaItem({
    @required this.type,
    @required this.url,
  });

  @override
  List get props => [
    type,
    url,
  ];

  @override
  bool get stringify => true;
}