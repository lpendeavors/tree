import 'dart:async';

import '../../bloc/bloc_provider.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../data/request/firestore_request_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/post_entity.dart';
import '../../models/old/user_entity.dart';
import './explore_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialExploreState = ExploreState(
  error: null,
  isLoading: true,
  requestItems: [],
  connectionItems: [],
  postItems: [],
);

class ExploreBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function(ConnectionItem) removeConnection;
  final void Function(ConnectionItem) addConnection;
  final void Function(ConnectionItem) acceptConnection;
  final void Function(ConnectionItem) declineConnection;

  ///
  /// Output streams
  ///
  final ValueStream<ExploreState> exploreState$;
  final ValueStream<bool> isLoading$;
  final Stream<ExploreMessage> addConnectionMessage$;
  final Stream<ExploreMessage> removeConnectionMessage$;
  final Stream<ExploreMessage> acceptConnectionMessage$;
  final Stream<ExploreMessage> declineConnectionMessage$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ExploreBloc._({
    @required this.isLoading$,
    @required this.exploreState$,
    @required this.addConnectionMessage$,
    @required this.removeConnectionMessage$,
    @required this.acceptConnectionMessage$,
    @required this.declineConnectionMessage$,
    @required this.addConnection,
    @required this.removeConnection,
    @required this.acceptConnection,
    @required this.declineConnection,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ExploreBloc({
    @required UserBloc userBloc,
    @required FirestorePostRepository postRepository,
    @required FirestoreUserRepository userRepository,
    @required FirestoreRequestRepository requestRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(postRepository != null, 'postRepository cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(requestRepository != null, 'requestRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final addConnectionSubject = PublishSubject<ConnectionItem>();
    final removeConnectionSubject = PublishSubject<ConnectionItem>();
    final acceptConnectionSubject = PublishSubject<ConnectionItem>();
    final declineConnectionSubject = PublishSubject<ConnectionItem>();

    ///
    /// Streams
    ///
    final addConnectionMessage$ = addConnectionSubject.exhaustMap((connection) {
      print('add ${connection.name}');
      return saveAddConnection(
        requestRepository,
        connection,
        userBloc.loginState$.value,
      );
    }).publish();

    final removeConnectionMessage$ = removeConnectionSubject
        .exhaustMap((connection) => saveRemoveConnection(connection))
        .publish();

    final acceptConnectionMessage$ = acceptConnectionSubject
        .exhaustMap((connection) => saveAcceptConnection(connection))
        .publish();

    final declineConnectionMessage$ = declineConnectionSubject
        .exhaustMap((connection) => saveDeclineConnection(connection))
        .publish();

    final exploreState$ = _getExploreList(
      userBloc,
      postRepository,
      userRepository,
      requestRepository,
    ).publishValueSeeded(_kInitialExploreState);

    final subscriptions = <StreamSubscription>[
      exploreState$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingSubject,
    ];

    return ExploreBloc._(
        addConnection: addConnectionSubject.add,
        removeConnection: removeConnectionSubject.add,
        acceptConnection: acceptConnectionSubject.add,
        declineConnection: declineConnectionSubject.add,
        isLoading$: isLoadingSubject,
        addConnectionMessage$: addConnectionMessage$,
        removeConnectionMessage$: removeConnectionMessage$,
        acceptConnectionMessage$: acceptConnectionMessage$,
        declineConnectionMessage$: declineConnectionMessage$,
        exploreState$: exploreState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<ExploreState> _toState(
    LoginState loginState,
    FirestoreUserRepository userRepository,
    FirestorePostRepository postRepository,
    FirestoreRequestRepository requestRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialExploreState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.combineLatest6(
          userRepository.getSuggestionsByChurch(church: loginState.church),
          userRepository.getSuggestionsByCity(city: loginState.city),
          userRepository.getPublicFigures(),
          userRepository.get(),
          postRepository.postsForCollage(),
          requestRepository.requestsByUser(uid: loginState.uid), (churchUsers,
              cityUsers, publicFigures, newestUsers, posts, requests) {
        var filiteredPosts = (posts as List<PostEntity>).where((p) {
          return p.postData != null && p.postData.length > 0;
        }).toList();

        filiteredPosts.sort((a, b) => b.time.compareTo(a.time));
        (newestUsers as List<UserEntity>)
            .sort((a, b) => b.time.compareTo(a.time));

        var suggestions = churchUsers as List<UserEntity>;
        suggestions.addAll(publicFigures);
        suggestions.addAll(cityUsers);
        suggestions.addAll(newestUsers);
        suggestions.toSet().where((s) => s.uid != loginState.uid).toList();

        return _kInitialExploreState.copyWith(
          connectionItems: _userEntitiesToItems(suggestions),
          postItems: _postEntitiesToItems(filiteredPosts),
          requestItems: _userEntitiesToItems(requests),
          isLoading: false,
        );
      }).startWith(_kInitialExploreState).onErrorReturnWith((e) {
        return _kInitialExploreState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialExploreState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<ConnectionItem> _userEntitiesToItems(
    List<UserEntity> entities,
  ) {
    return entities.map((entity) {
      return ConnectionItem(
        id: entity.id,
        city: entity.city ?? "None",
        church:
            entity.churchInfo != null ? entity.churchInfo.churchName : "None",
        isChurch: entity.isChurch ?? false,
        image: entity.image,
        name: entity.isChurch ? entity.churchName : entity.fullName,
        denomination: entity.churchInfo != null
            ? entity.churchInfo.churchDenomination
            : "None",
      );
    }).toList();
  }

  static List<PostItem> _postEntitiesToItems(
    List<PostEntity> entities,
  ) {
    return entities.map((entity) {
      return PostItem(
        id: entity.documentId,
        image: _getPostMedia(entity) ?? "",
        type: _getPostType(entity),
      );
    }).toList();
  }

  static Stream<ExploreState> _getExploreList(
    UserBloc userBloc,
    FirestorePostRepository postRepository,
    FirestoreUserRepository userRepository,
    FirestoreRequestRepository requestRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        userRepository,
        postRepository,
        requestRepository,
      );
    });
  }

  static String _getPostMedia(
    PostEntity entity,
  ) {
    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        return entity.postData[0].imageUrl;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static int _getPostType(
    PostEntity entity,
  ) {
    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        return entity.postData[0].assetType;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Stream<ExploreMessage> saveAddConnection(
    FirestoreRequestRepository requestRepository,
    ConnectionItem connection,
    LoginState loginState,
  ) async* {
    print('[DEBUG] ExploreBloc#saveAddConnection');
    try {
      // requestRepository.saveRequest(
      //   to: connection.name,
      //   toUser: connection.id,
      //   image: connection.image,
      //   from: (loginState as LoggedInUser).uid,
      //   fromUser: (loginState as LoggedInUser).fullName,
      //   token: (loginState as LoggedInUser).token,
      // );
      yield ConnectionAddedSuccess();
    } catch (e) {
      yield ConnectionAddedError(e);
    }
  }

  static Stream<ExploreMessage> saveRemoveConnection(
      ConnectionItem connection) async* {
    print('[DEBUG] ExploreBloc#saveAddConnection');
  }

  static Stream<ExploreMessage> saveAcceptConnection(
      ConnectionItem connection) async* {
    print('[DEBUG] ExploreBloc#saveAddConnection');
  }

  static Stream<ExploreMessage> saveDeclineConnection(
      ConnectionItem connection) async* {
    print('[DEBUG] ExploreBloc#saveAddConnection');
  }
}
