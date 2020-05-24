import 'dart:async';

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


  ///
  /// Output streams
  ///
  final ValueStream<EventsListState> eventsListState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  EventsBloc._({
    @required this.eventsListState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory EventsBloc({
    @required UserBloc userBloc,
    @required FirestoreEventRepository eventRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(eventRepository != null, 'eventRepository cannot be null');

    ///
    /// Stream controllers
    ///


    ///
    /// Streams
    ///
    final eventsListState$ = _getEventsList(
      userBloc,
      eventRepository,
    ).publishValueSeeded(_kInitialEventsListState);

    final subscriptions = <StreamSubscription>[
      eventsListState$.connect(),
    ];

    return EventsBloc._(
      eventsListState$: eventsListState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<EventsListState> _toState(
    LoginState loginState,
    FirestoreEventRepository eventRepository,
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
      return eventRepository.get()
        .map((entities) {
          return _entitiesToEventItems(entities);
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

    return Stream.value(
      _kInitialEventsListState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<EventItem> _entitiesToEventItems(
    List<EventEntity> entities,
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
      );
    }).toList();
  }

  static Stream<EventsListState> _getEventsList(
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        eventRepository,
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
}