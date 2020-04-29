import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/event/firestore_event_repository.dart';
import '../../models/event_entity.dart';
import '../../pages/event_edit/event_edit_state.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';

bool _isTitleValid(String title) {
  return title.length >= 3;
}

bool _isDescriptionValid(String desc) {
  return desc.length >= 3;
}

bool _isStartDateValid(DateTime start) {
  if (start != null) {
    return start.isAfter(DateTime.now());
  }
  return false;
}

bool _isStartTimeValid(DateTime start) {
  return start != null;
}

bool _isEndDateValid(DateTime end) {
  if (end != null) {
    return end.isAfter(DateTime.now());
  }
  return false;
}

bool _isEndTimeValid(DateTime end) {
  return end != null;
}

bool _isValidImage(String imageUrl) {
  return imageUrl.isNotEmpty;
}

bool _isValidWebAddress(String webAddress) {
  return webAddress.isNotEmpty;
}

bool _isValidCost(double cost) {
  return cost != null;
}

bool _isValidVenue(String venue) {
  return venue.isNotEmpty;
}

bool _isValidBudget(double budget) {
  return budget != null;
}

const _kInitialEventDetailsState = EventEditState(
  error: null,
  isLoading: true,
  eventDetails: null,
);

class EventEditBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() saveEvent;
  final void Function(String) titleChanged;
  final void Function(String) descriptionChanged;
  final void Function(DateTime) startDateChanged;
  final void Function(DateTime) startTimeChanged;
  final void Function(DateTime) endDateChanged;
  final void Function(DateTime) endTimeChanged;
  final void Function(String) imageChanged;
  final void Function(String) webAddressChanged;
  final void Function(String) costChanged;
  final void Function(String) venueChanged;
  final void Function(String) budgetChanged;

  ///
  /// Output streams
  ///
  final ValueStream<EventEditState> eventEditState$;
  final Stream<EventTitleError> titleError$;
  final Stream<EventStartDateError> startDateError$;
  final Stream<EventStartTimeError> startTimeError$;
  final Stream<EventEndDateError> endDateError$;
  final Stream<EventEndTimeError> endTimeError$;
  final Stream<EventImageError> imageError$;
  final Stream<EventWebAddressError> webAddressError$;
  final Stream<EventCostError> costError$;
  final Stream<EventVenueError> venueError$;
  final Stream<EventBudgetError> budgetError$;
  final Stream<EventEditedMessage> message$;
  final ValueStream<bool> isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  EventEditBloc._({
    @required this.saveEvent,
    @required this.titleChanged,
    @required this.descriptionChanged,
    @required this.startDateChanged,
    @required this.startTimeChanged,
    @required this.endDateChanged,
    @required this.endTimeChanged,
    @required this.imageChanged,
    @required this.webAddressChanged,
    @required this.costChanged,
    @required this.venueChanged,
    @required this.budgetChanged,
    @required this.eventEditState$,
    @required this.titleError$,
    @required this.startDateError$,
    @required this.startTimeError$,
    @required this.endDateError$,
    @required this.endTimeError$,
    @required this.imageError$,
    @required this.webAddressError$,
    @required this.costError$,
    @required this.venueError$,
    @required this.budgetError$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory EventEditBloc({
    String eventId,
    int eventType,
    @required UserBloc userBloc,
    @required FirestoreEventRepository eventRepository
  }) {
    ///
    /// Assert
    ///
    assert((eventId != null || eventType != null), 'eventId and eventType cannot be null');
    assert(userBloc != null, 'userBloc cannot be null');
    assert(eventRepository != null, 'eventRepository cannot be null');

    ///
    /// Stream controller
    ///
    final titleSubject = BehaviorSubject<String>.seeded('');
    final descriptionSubject = BehaviorSubject<String>.seeded('');
    final startDateSubject = BehaviorSubject<DateTime>.seeded(null);
    final startTimeSubject = BehaviorSubject<DateTime>.seeded(null);
    final endDateSubject = BehaviorSubject<DateTime>.seeded(null);
    final endTimeSubject = BehaviorSubject<DateTime>.seeded(null);
    final imageSubject = BehaviorSubject<String>.seeded('');
    final webAddressSubject = BehaviorSubject<String>.seeded('');
    final costSubject = BehaviorSubject<String>.seeded(null);
    final venueSubject = BehaviorSubject<String>.seeded('');
    final budgetSubject = BehaviorSubject<String>.seeded(null);
    final saveEventSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final titleError$ = titleSubject.map((title) {
      if (_isTitleValid(title)) return null;
      return const EventTitleError();
    }).share();

    final descriptionError$ = descriptionSubject.map((description) {
      if (_isDescriptionValid(description)) return null;
      return const EventDescriptionError();
    });

    final startDateError$ = startDateSubject.map((date) {
      if (_isStartDateValid(date)) return null;
      return const EventStartDateError();
    }).share();

    final startTimeError$ = startTimeSubject.map((time) {
      if (_isStartTimeValid(time)) return null;
      return const EventStartTimeError();
    }).share();

    final endDateError$ = endDateSubject.map((date) {
      if (_isEndDateValid(date)) return null;
      return const EventEndDateError();
    }).share();

    final endTimeError$ = endTimeSubject.map((time) {
      if (_isEndTimeValid(time)) return null;
      return const EventEndTimeError();
    }).share();

    final imageError$ = imageSubject.map((image) {
      if (_isValidImage(image)) return null;
      return const EventImageError();
    }).share();

    final webAddressError$ = webAddressSubject.map((address) {
      if (_isValidWebAddress(address)) return null;
      return const EventWebAddressError();
    }).share();

    final costError$ = costSubject.map((cost) {
      if (cost != null) {
        if (_isValidCost(double.parse(cost))) return null;
      }
      return const EventCostError();
    }).share();

    final venueError$ = venueSubject.map((venue) {
      if (_isValidVenue(venue)) return null;
      return const EventVenueError();
    }).share();

    final budgetError$ = budgetSubject.map((budget) {
      if (budget != null) {
        if (_isValidBudget(double.parse(budget))) return null;
      }
      return const EventBudgetError();
    }).share();

    final allFieldsAreValid$ = Rx.combineLatest(
      [
        titleError$,
        descriptionError$,
        startDateError$,
        startTimeError$,
        endDateError$,
        endTimeError$,
        imageError$,
        webAddressError$,
        costError$,
        venueError$,
        budgetError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = saveEventSubject
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => performSave(
          eventId ?? null,
          userBloc,
          eventRepository,
          titleSubject.value,
          startDateSubject.value,
          startTimeSubject.value,
          endDateSubject.value,
          endTimeSubject.value,
          imageSubject.value,
          webAddressSubject.value,
          double.parse(costSubject.value),
          venueSubject.value,
          double.parse(budgetSubject.value),
          isLoadingSubject,
        )
      ).publish();

    final eventEditState$ = _getEventDetails(
      userBloc,
      eventRepository,
      eventId,
    ).publishValueSeeded(_kInitialEventDetailsState);


    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      eventEditState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      titleSubject,
      startDateSubject,
      startTimeSubject,
      endDateSubject,
      endTimeSubject,
      imageSubject,
      webAddressSubject,
      costSubject,
      venueSubject,
      budgetSubject,
      isLoadingSubject,
    ];

    return EventEditBloc._(
      titleChanged: titleSubject.add,
      startDateChanged: startDateSubject.add,
      startTimeChanged: startTimeSubject.add,
      endDateChanged: endDateSubject.add,
      endTimeChanged: endTimeSubject.add,
      imageChanged: imageSubject.add,
      webAddressChanged: webAddressSubject.add,
      costChanged: costSubject.add,
      venueChanged: venueSubject.add,
      budgetChanged: budgetSubject.add,
      titleError$: titleError$,
      startDateError$: startDateError$,
      startTimeError$: startTimeError$,
      endDateError$: endDateError$,
      endTimeError$: endTimeError$,
      imageError$: imageError$,
      webAddressError$: webAddressError$,
      costError$: costError$,
      venueError$: venueError$,
      budgetError$: budgetError$,
      eventEditState$: eventEditState$,
      isLoading$: isLoadingSubject,
      saveEvent: () => saveEventSubject.add(null),
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  static Stream<EventEditState> _toState(
    LoginState loginState,
    FirestoreEventRepository eventRepository,
    String eventId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialEventDetailsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (eventId != null) {
        return eventRepository.getById(eventId)
          .map((entity) {
            return _entityToEventItem(
              entity,
            );
        })
        .map((eventItem) {
          return _kInitialEventDetailsState.copyWith(
            eventDetails: eventItem,
            isLoading: false,
          );
        })
        .startWith(_kInitialEventDetailsState)
        .onErrorReturnWith((e) {
          return _kInitialEventDetailsState.copyWith(
            error: e,
            isLoading: false,
          );
        });
      } else {
        return Stream.value(
          _kInitialEventDetailsState.copyWith(
            isLoading: false,
          ),
        );
      }
    }

    return Stream.value(
      _kInitialEventDetailsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static EventEditItem _entityToEventItem(
    EventEntity entity
  ) {
    return EventEditItem(
      id: entity.documentId,
      title: entity.title,
      startDate: entity.startDate.toDate(),
      startTime: entity.startDate.toDate(),
      endDate: entity.endDate.toDate(),
      endTime: entity.endDate.toDate(),
      image: entity.owner.photo,
      eventCost: entity.cost,
      venue: entity.location.address,
    );
  }

  static Stream<EventEditState> _getEventDetails(
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
    String eventId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        eventRepository,
        eventId
      );
    });
  }

  static Stream<EventEditedMessage> performSave(
    String eventId,
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
    String eventTitle,
    DateTime startDate,
    DateTime startTime,
    DateTime endDate,
    DateTime endTime,
    String image,
    String webAddress,
    double cost,
    String venue,
    double budget,
    Sink<bool> isLoading,
  ) async* {
    print('[DEBUG] saveEvent');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        await eventRepository.save(
          loginState.uid,
          eventId,
          eventTitle,
          startDate,
          startTime,
          endDate,
          endTime,
          image,
          webAddress,
          cost,
          venue,
          budget,
        );
        yield EventEditedMessageSuccess(eventTitle);
      } catch (e) {
        yield EventEditedMessageError(e);
      }
    } else {
      yield EventEditedMessageError(NotLoggedInError());
    }
  }
}
