import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/event/firestore_event_repository.dart';
import '../../models/old/event_entity.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import './event_edit_state.dart';

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

bool _isValidImage(List<String> imageUrls) {
  return imageUrls.isNotEmpty;
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
  final void Function(List<String>) imagesChanged;
  final void Function(String) webAddressChanged;
  final void Function(String) costChanged;
  final void Function(String) venueChanged;
  final void Function(Tuple2<double, double>) venueGeoChanged;
  final void Function(String) budgetChanged;
  final void Function(bool) isSponsoredChanged;
  final void Function(bool) geoLoadingChanged;

  ///
  /// Output streams
  ///
  final ValueStream<EventEditState> eventEditState$;
  final Stream<EventTitleError> titleError$;
  final Stream<EventDescriptionError> descriptionError$;
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
  final ValueStream<bool> geoLoading$;

  final ValueStream<DateTime> startDate$;
  final ValueStream<DateTime> startTime$;
  final ValueStream<DateTime> endDate$;
  final ValueStream<DateTime> endTime$;
  final ValueStream<bool> isSponsored$;
  final ValueStream<List<String>> images$;
  final ValueStream<String> cost$;
  final ValueStream<String> venue$;
  final ValueStream<String> budget$;

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
    @required this.imagesChanged,
    @required this.webAddressChanged,
    @required this.costChanged,
    @required this.venueChanged,
    @required this.venueGeoChanged,
    @required this.budgetChanged,
    @required this.isSponsoredChanged,
    @required this.geoLoadingChanged,
    @required this.startDate$,
    @required this.startTime$,
    @required this.endDate$,
    @required this.endTime$,
    @required this.isSponsored$,
    @required this.images$,
    @required this.cost$,
    @required this.venue$,
    @required this.budget$,
    @required this.eventEditState$,
    @required this.titleError$,
    @required this.descriptionError$,
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
    @required this.geoLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory EventEditBloc(
      {String eventId,
      int eventType,
      @required UserBloc userBloc,
      @required FirestoreEventRepository eventRepository}) {
    ///
    /// Assert
    ///
    assert((eventId != null || eventType != null),
        'eventId and eventType cannot be null');
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
    final imagesSubject = BehaviorSubject<List<String>>.seeded([]);
    final webAddressSubject = BehaviorSubject<String>.seeded('');
    final costSubject = BehaviorSubject<String>.seeded('0.00');
    final venueSubject = BehaviorSubject<String>.seeded('');
    final venueGeoSubject =
        BehaviorSubject<Tuple2<double, double>>.seeded(null);
    final budgetSubject = BehaviorSubject<String>.seeded('0.00');
    final isSponsoredSubject = BehaviorSubject<bool>.seeded(false);
    final saveEventSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final geoLoadingSubject = BehaviorSubject<bool>.seeded(false);

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

    final imageError$ = imagesSubject.map((images) {
      if (_isValidImage(images)) return null;
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
        //webAddressError$,
        //costError$,
        venueError$,
        //budgetError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = saveEventSubject
        .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
        .where((isValid) => isValid)
        .exhaustMap((_) => performSave(
              eventId ?? null,
              userBloc,
              eventRepository,
              titleSubject.value,
              descriptionSubject.value,
              eventType,
              startDateSubject.value,
              startTimeSubject.value,
              endDateSubject.value,
              endTimeSubject.value,
              imagesSubject.value,
              webAddressSubject.value,
              double.parse(costSubject.value),
              venueSubject.value,
              venueGeoSubject.value,
              double.parse(budgetSubject.value),
              isSponsoredSubject.value,
              isLoadingSubject,
            ))
        .publish();

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
      imagesSubject,
      webAddressSubject,
      costSubject,
      venueSubject,
      budgetSubject,
      isLoadingSubject,
      geoLoadingSubject,
    ];

    return EventEditBloc._(
        titleChanged: titleSubject.add,
        descriptionChanged: descriptionSubject.add,
        startDateChanged: startDateSubject.add,
        startTimeChanged: startTimeSubject.add,
        endDateChanged: endDateSubject.add,
        endTimeChanged: endTimeSubject.add,
        imagesChanged: imagesSubject.add,
        webAddressChanged: webAddressSubject.add,
        costChanged: costSubject.add,
        venueChanged: venueSubject.add,
        venueGeoChanged: venueGeoSubject.add,
        budgetChanged: budgetSubject.add,
        isSponsoredChanged: isSponsoredSubject.add,
        geoLoadingChanged: geoLoadingSubject.add,
        startDate$: startDateSubject.stream,
        startTime$: startTimeSubject.stream,
        endDate$: endDateSubject.stream,
        endTime$: endTimeSubject.stream,
        isSponsored$: isSponsoredSubject.stream,
        images$: imagesSubject.stream,
        cost$: costSubject.stream,
        venue$: venueSubject.stream,
        budget$: budgetSubject.stream,
        titleError$: titleError$,
        descriptionError$: descriptionError$,
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
        geoLoading$: geoLoadingSubject,
        saveEvent: () => saveEventSubject.add(null),
        message$: message$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  static Stream<EventEditState> _toState(
    LoginState loginState,
    FirestoreEventRepository eventRepository,
    String eventId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialEventDetailsState.copyWith(
            error: NotLoggedInError(), isLoading: false),
      );
    }

    if (loginState is LoggedInUser) {
      if (eventId != null) {
        return eventRepository
            .getById(eventId)
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

  static EventEditItem _entityToEventItem(EventEntity entity) {
    return EventEditItem(
      id: entity.documentId,
      title: entity.eventTitle,
      description: entity.eventDetails,
      startDate: DateTime.fromMillisecondsSinceEpoch(entity.eventStartDate),
      startTime: DateTime.fromMillisecondsSinceEpoch(entity.eventStartTime),
      endDate: DateTime.fromMillisecondsSinceEpoch(entity.eventEndDate),
      endTime: DateTime.fromMillisecondsSinceEpoch(entity.eventEndTime),
      media: _getEventMedia(entity),
      eventCost: entity.eventPrice,
      venue: entity.location,
      isSponsored: entity.isSponsored,
      budget: entity.sponsorFee,
      webAddress: entity.eventWebAddress ?? '',
    );
  }

  static Stream<EventEditState> _getEventDetails(
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
    String eventId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(loginState, eventRepository, eventId);
    });
  }

  static List<EventMediaItem> _getEventMedia(
    EventEntity entity,
  ) {
    return (entity.eventData ?? []).map((data) {
      return EventMediaItem(
        type: EventMediaType.values[data.type],
        url: data.imageUrl,
      );
    }).toList();
  }

  static Stream<EventEditedMessage> performSave(
    String eventId,
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
    String eventTitle,
    String eventDescription,
    int eventType,
    DateTime startDate,
    DateTime startTime,
    DateTime endDate,
    DateTime endTime,
    List<String> images,
    String webAddress,
    double cost,
    String venue,
    Tuple2<double, double> venueGeo,
    double budget,
    bool isSponsored,
    Sink<bool> isLoading,
  ) async* {
    print('[DEBUG] EventEditBloc#performSave');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoading.add(true);
        await eventRepository.save(
          loginState.uid,
          loginState.email,
          loginState.fullName,
          loginState.image,
          loginState.token,
          loginState.isChurch,
          eventId,
          eventTitle,
          eventDescription,
          eventType,
          startDate,
          startTime,
          endDate,
          endTime,
          images,
          webAddress,
          cost,
          venue,
          venueGeo.item1,
          venueGeo.item2,
          budget,
          isSponsored,
          loginState.isAdmin,
          loginState.isVerified,
        );
        yield EventEditedMessageSuccess(eventTitle);
      } catch (e) {
        yield EventEditedMessageError(e);
      } finally {
        isLoading.add(false);
      }
    } else {
      yield EventEditedMessageError(NotLoggedInError());
    }
  }
}
