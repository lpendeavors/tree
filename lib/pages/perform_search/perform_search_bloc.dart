import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/bloc/bloc_provider.dart';
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/models/old/user_entity.dart';
import '../../pages/perform_search/perform_search_state.dart';


const _kInitialSearchState = SearchState(
  results: [],
  isLoading: false,
  error: null,
);

class SearchBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function(String query) search;

  ///
  /// Output streams
  ///
  final ValueStream<SearchState> searchState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  SearchBloc._({
    @required this.searchState$,
    @required this.search,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory SearchBloc({
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Controllers
    ///
    final searchController = BehaviorSubject<String>();

    ///
    /// Streams
    ///
    final searchState$ = searchController
        .asyncMap((query){
          print('hey $query');
          return _toState(
            query,
            userRepository,
          );
        }
      ).publishValueSeeded(_kInitialSearchState);

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      searchState$.connect()
    ];

    final controllers = <StreamController>[
      searchController,
    ];

    return SearchBloc._(
      searchState$: searchState$,
      search: (query) => searchController.add(query),
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Future<SearchState> _toState(
    String query,
    FirestoreUserRepository userRepository,
  ) {
    print('running search $query');
    if(query.length > 0) {
      return _runSearch(query, userRepository).then((results) {
        print('_toState ${results.length}');
        return _kInitialSearchState.copyWith(
          results: results,
          isLoading: false,
          error: null,
        );
      });
    }else{
      return Future.value(
        _kInitialSearchState.copyWith(
          results: [],
          isLoading: false,
          error: null,
        )
      );
    }
  }

  static Future<List<UserEntity>> _runSearch(
    String query,
    FirestoreUserRepository userRepository,
  ) {
    return userRepository.runSearchQuery(query);
  }
}