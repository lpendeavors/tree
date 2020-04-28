import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/event/firestore_event_repository.dart';
import '../../models/event_entity.dart';
import '../../models/user_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './event_details_state.dart';

const _kInitialEventDetailsState = EventDetailsState(
  eventDetails: null,
  isLoading: true,
  error: false,
);

class EventDetailsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function() attendEvent;
  Function() cancelAttendance;

  ///
  /// Output streams
  ///
  final ValueStream<EventDetailsState> eventDetailsState$;
  final Stream<EventDetailsMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  EventDetailsBloc._({
    @required this.attendEvent,
    @required this.cancelAttendance,
    @required this.eventDetailsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory EventDetailsBloc({
    @required UserBloc userBloc,
    @required FirestoreEventRepository eventRepository,
    @required String eventId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(eventRepository != null, 'eventRepository cannot be null');
    assert(eventId != null, 'eventId cannot be null');

    ///
    /// Stream controllers
    ///
    final attendEvent = PublishSubject<String>(sync: true);
    final cancelAttendance = PublishSubject<String>(sync: true);

    ///
    /// Streams
    ///
    final message$ = _getEventDetailsMessage(
      attendEvent,
      cancelAttendance,
      userBloc,
      eventRepository,
    );

    final eventDetailsState$ = _getEventDetails(
        userBloc,
        eventRepository,
        eventId,
      ).publishValueSeeded(_kInitialEventDetailsState);

    final subscriptions = <StreamSubscription>[
      eventDetailsState$.connect(),
      message$.connect(),
    ];

    return EventDetailsBloc._(
      attendEvent: () => attendEvent.add(null),
      cancelAttendance: () => cancelAttendance.add(null),
      eventDetailsState$: eventDetailsState$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<EventDetailsState> _toState(
    LoginState loginState,
    FirestoreEventRepository eventRepository,
    String eventId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialEventDetailsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return eventRepository.getById(eventId)
        .map((entities) {
          return _entityToEventItem(
            entities,
            loginState,
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
    }

    return Stream.value(
      _kInitialEventDetailsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static EventDetailItem _entityToEventItem(
    EventEntity entity,
    LoginState loginState,
  ) {
    return EventDetailItem(
      id: entity.documentId,
      title: entity.eventTitle,
      image: entity.image,
      attendees: [],
      isSponsored: entity.isSponsored,
      isMine: entity.ownerId == (loginState as LoggedInUser).uid,
      isRejected: entity.status == 2,
      reason: entity.reason,
      isAttending: false,
      latitude: entity.eventLatitude,
      longitude: entity.eventLongitude,
      status: entity.status,
      webAddress: entity.eventWebAddress,
      type: entity.type,
      price: entity.eventPrice,
      location: entity.location,
      details: entity.eventDetails,
    );
  }

  static Stream<EventDetailsState> _getEventDetails(
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
    String eventId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        eventRepository,
        eventId,
      );
    });
  }

  static ConnectableStream<EventDetailsMessage> _getEventDetailsMessage(
    Stream<String> attendEvent,
    Stream<String> cancelAttendance,
    UserBloc userBloc,
    FirestoreEventRepository eventRepository,
  ) {
    return Rx.combineLatest([
      attendEvent,
      cancelAttendance,
    ], (message) {

      var loginState = userBloc.loginState$.value;
      if (loginState is Unauthenticated) {

      }

      if (loginState is LoggedInUser) {
        print(message);
      }
    }).publish();
  }
}