import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/bloc/bloc_provider.dart';
import 'package:treeapp/data/event/firestore_event_repository.dart';
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/data/group/firestore_group_repository.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/pages/perform_search/perform_search_page.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import '../../pages/perform_search/perform_search_state.dart';
import '../../user_bloc/user_bloc.dart';

const _kInitialSearchState = SearchState(
  results: [],
  user: null,
  isLoading: false,
  error: null,
);

class SearchBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function(String query) search;
  final void Function(String user) makeAdmin;
  final void Function(String user) removeAdmin;

  ///
  /// Output streams
  ///
  final ValueStream<SearchState> searchState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  SearchBloc._({
    @required this.makeAdmin,
    @required this.removeAdmin,
    @required this.searchState$,
    @required this.search,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory SearchBloc({
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
    @required FirestoreEventRepository eventRepository,
    @required FirestoreGroupRepository groupRepository,
    @required SearchType searchType,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(eventRepository != null, 'eventRepository cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(searchType != null, 'searchType cannot be null');

    ///
    /// Controllers
    ///
    final searchController = BehaviorSubject<String>();

    ///
    /// Streams
    ///
    final searchState$ = searchController.asyncMap((query) {
      return _toState(
          query, userRepository, eventRepository, groupRepository, searchType);
    }).publishValueSeeded(_kInitialSearchState);

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      searchState$.connect(),
    ];

    final controllers = <StreamController>[
      searchController,
    ];

    return SearchBloc._(
      searchState$: searchState$,
      search: (query) => searchController.add(query),
      makeAdmin: (user) => _toggleAdmin(true, user, userRepository, userBloc),
      removeAdmin: (user) =>
          _toggleAdmin(false, user, userRepository, userBloc),
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
    );
  }

  @override
  void dispose() => _dispose();

  static Future<SearchState> _toState(
      String query,
      FirestoreUserRepository userRepository,
      FirestoreEventRepository eventRepository,
      FirestoreGroupRepository groupRepository,
      SearchType searchType) {
    if (query.length > 0) {
      return _runSearch(query, userRepository, eventRepository, groupRepository,
              searchType)
          .then((results) {
        return _getLogin(userRepository).then((value) {
          return _kInitialSearchState.copyWith(
            results: results,
            user: value,
            isLoading: false,
            error: null,
          );
        });
      });
    } else {
      return Future.value(_kInitialSearchState.copyWith(
        results: [],
        isLoading: false,
        error: null,
      ));
    }
  }

  static Future<List<dynamic>> _runSearch(
      String query,
      FirestoreUserRepository userRepository,
      FirestoreEventRepository eventRepository,
      FirestoreGroupRepository groupRepository,
      SearchType searchType) {
    if (searchType == SearchType.USERS || searchType == SearchType.CHURCH) {
      return userRepository.runSearchQuery(query, searchType);
    } else if (searchType == SearchType.EVENT) {
      return eventRepository.runSearchQuery(query);
    } else {
      return groupRepository.runSearchQuery(query);
    }
  }

  static Future<UserEntity> _getLogin(
    FirestoreUserRepository userRepository,
  ) {
    return userRepository.user().first;
  }

  static Future<void> _toggleAdmin(
    bool makeAdmin,
    String userId,
    FirestoreUserRepository userRepository,
    UserBloc userBloc,
  ) async {
    print('[DEBUG] PerformSearchBloc#toggleAdmin');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      print(makeAdmin);
      await userRepository.toggleAdmin(
        makeAdmin,
        userId,
      );
    }
  }
}
