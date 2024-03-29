import 'dart:async';

import 'package:tuple/tuple.dart';

import '../../bloc/bloc_provider.dart';
import '../../data/event/firestore_event_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/event_entity.dart';
import './events_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialEventsListState = EventsListState(
  error: null,
  isLoading: true,
  eventItems: [],
  myEvents: [],
);

class EventsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function(bool) hideEventsOnMapChanged;
  final void Function(String) deleteEvent;
  final void Function(Tuple2<String, int>) updateStatus;

  ///
  /// Output streams
  ///
  final ValueStream<bool> hideEventsOnMap$;
  final ValueStream<EventsListState> eventsListState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  EventsBloc._({
    @required this.hideEventsOnMap$,
    @required this.eventsListState$,
    @required this.hideEventsOnMapChanged,
    @required this.deleteEvent,
    @required this.updateStatus,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory EventsBloc({
    @required UserBloc userBloc,
    @required FirestoreEventRepository eventRepository,
    @required EventFilter filter,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(eventRepository != null, 'eventRepository cannot be null');
    assert(filter != null, 'filter cannot be null');

    ///
    /// Stream controllers
    ///
    final hideEventsOnMapSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final eventsListState$ = _getEventsList(
      userBloc,
      eventRepository,
      filter,
    ).publishValueSeeded(_kInitialEventsListState);

    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      eventsListState$.connect(),
    ];

    final controllers = <StreamController>[
      hideEventsOnMapSubject,
    ];

    return EventsBloc._(
        hideEventsOnMap$: hideEventsOnMapSubject.stream,
        hideEventsOnMapChanged: hideEventsOnMapSubject.add,
        eventsListState$: eventsListState$,
        deleteEvent: (eventId) =>
            _deleteEvent(eventRepository, userBloc, eventId),
        updateStatus: (values) =>
            _updateStatus(eventRepository, userBloc, values),
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<EventsListState> _toState(
    LoginState loginState,
    FirestoreEventRepository eventRepository,
    EventFilter filter,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialEventsListState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (filter == EventFilter.none) {
        return eventRepository
            .get()
            .map((entities) {
              return _entitiesToEventItems(
                entities,
                loginState.uid,
                loginState.isAdmin,
              );
            })
            .map((eventItems) {
              return _kInitialEventsListState.copyWith(
                isLoading: false,
                eventItems: eventItems,
                myEvents: _getEventsImAttending(eventItems, loginState.uid),
              );
            })
            .startWith(_kInitialEventsListState)
            .onErrorReturnWith((e) {
              return _kInitialEventsListState.copyWith(
                error: e,
                isLoading: false,
              );
            });
      }

      if (filter == EventFilter.pending) {
        return eventRepository
            .getPending()
            .map((entities) {
              return _entitiesToEventItems(
                entities,
                loginState.uid,
                loginState.isAdmin,
              );
            })
            .map((eventItems) {
              return _kInitialEventsListState.copyWith(
                isLoading: false,
                eventItems: eventItems,
                myEvents: _getEventsImAttending(eventItems, loginState.uid),
              );
            })
            .startWith(_kInitialEventsListState)
            .onErrorReturnWith((e) {
              return _kInitialEventsListState.copyWith(
                error: e,
                isLoading: false,
              );
            });
      }

      if (filter == EventFilter.inactive) {
        return eventRepository
            .getInactive()
            .map((entities) {
              return _entitiesToEventItems(
                entities,
                loginState.uid,
                loginState.isAdmin,
              );
            })
            .map((eventItems) {
              return _kInitialEventsListState.copyWith(
                isLoading: false,
                eventItems: eventItems,
                myEvents: _getEventsImAttending(eventItems, loginState.uid),
              );
            })
            .startWith(_kInitialEventsListState)
            .onErrorReturnWith((e) {
              return _kInitialEventsListState.copyWith(
                error: e,
                isLoading: false,
              );
            });
      }

      if (filter == EventFilter.completed) {
        return eventRepository
            .getCompleted()
            .map((entities) {
              return _entitiesToEventItems(
                entities,
                loginState.uid,
                loginState.isAdmin,
              );
            })
            .map((eventItems) {
              return _kInitialEventsListState.copyWith(
                isLoading: false,
                eventItems: eventItems,
                myEvents: _getEventsImAttending(eventItems, loginState.uid),
              );
            })
            .startWith(_kInitialEventsListState)
            .onErrorReturnWith((e) {
              return _kInitialEventsListState.copyWith(
                error: e,
                isLoading: false,
              );
            });
      }
    }

    return Stream.value(
      _kInitialEventsListState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<EventItem> _entitiesToEventItems(
    List<EventEntity> entities,
    String uid,
    bool isAdmin,
  ) {
    entities.sort((a, b) => a.eventStartDate.compareTo(b.eventStartDate));
    return entities.map((entity) {
      return EventItem(
        id: entity.id,
        title: entity.eventTitle,
        details: entity.eventDetails,
        ownerId: entity.uid,
        image: entity.eventData[0].imageUrl,
        location: entity.location,
        eventType: entity.type,
        startDate: DateTime.fromMillisecondsSinceEpoch(entity.eventStartDate),
        isSponsored: entity.isSponsored,
        isAttending: entity.attending,
        isMine: entity.ownerId == uid,
        isAdmin: isAdmin,
      );
    }).toList();
  }

  static Stream<EventsListState> _getEventsList(
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
    EventFilter filter,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        eventRepository,
        filter,
      );
    });
  }

  static List<EventItem> _getEventsImAttending(
    List<EventItem> events,
    String uid,
  ) {
    if (events.isNotEmpty) {
      return events.where((event) {
        if (event.isAttending != null) {
          return event.isAttending.contains(uid);
        } else {
          return false;
        }
      }).toList();
    } else {
      return [];
    }
  }

  static Future<void> _deleteEvent(
    FirestoreEventRepository eventRepository,
    UserBloc userBloc,
    String eventId,
  ) async {
    var loginState = userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      await eventRepository.deleteEvent(eventId);
    }
  }

  static Future<void> _updateStatus(
    FirestoreEventRepository eventRepository,
    UserBloc userBloc,
    Tuple2<String, int> values,
  ) async {
    var loginState = userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      await eventRepository.updateStatus(values.item1, values.item2);
    }
  }
}
