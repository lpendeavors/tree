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
  final void Function(ConnectionItem) addConnection;
  final void Function(ConnectionItem) acceptConnection;
  final void Function(ConnectionItem) declineConnection;

  ///
  /// Output streams
  ///
  final ValueStream<ExploreState> exploreState$;
  final ValueStream<bool> isLoading$;
  final Stream<ExploreMessage> addConnectionMessage$;
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
    @required this.acceptConnectionMessage$,
    @required this.declineConnectionMessage$,
    @required this.addConnection,
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
    final addConnectionMessage$ = addConnectionSubject
        .exhaustMap((connection) => saveAddConnection(
              requestRepository,
              connection,
              userBloc.loginState$.value,
            ))
        .publish();

    final acceptConnectionMessage$ = acceptConnectionSubject
        .exhaustMap((connection) => saveAcceptConnection(
              requestRepository,
              connection,
              userBloc.loginState$.value,
            ))
        .publish();

    final declineConnectionMessage$ = declineConnectionSubject
        .exhaustMap((connection) => saveDeclineConnection(
              requestRepository,
              connection,
              userBloc.loginState$.value,
            ))
        .publish();

    final exploreState$ = _getExploreList(
      userBloc,
      postRepository,
      userRepository,
      requestRepository,
    ).publishValueSeeded(_kInitialExploreState);

    final subscriptions = <StreamSubscription>[
      exploreState$.connect(),
      addConnectionMessage$.connect(),
      acceptConnectionMessage$.connect(),
      declineConnectionMessage$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingSubject,
    ];

    return ExploreBloc._(
        addConnection: addConnectionSubject.add,
        acceptConnection: acceptConnectionSubject.add,
        declineConnection: declineConnectionSubject.add,
        isLoading$: isLoadingSubject,
        addConnectionMessage$: addConnectionMessage$,
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
      print('recieved=${loginState.receivedRequests}');
      return Rx.combineLatest6(
          userRepository.getSuggestionsByChurch(church: loginState.church),
          userRepository.getSuggestionsByCity(city: loginState.city),
          userRepository.getPublicFigures(),
          userRepository.get(),
          postRepository.postsForCollage(),
          loginState.receivedRequests.isNotEmpty
              ? requestRepository.requestsByUser(
                  uids: loginState.receivedRequests)
              : Stream.value(List<UserEntity>()),
          (churchUsers, cityUsers, publicFigures, newestUsers, posts,
              requests) {
        print(requests);
        var filiteredPosts = (posts as List<PostEntity>).where((p) {
          return p.postData != null && p.postData.length > 0;
        }).toList();

        filiteredPosts.sort((a, b) => b.time.compareTo(a.time));
        // (newestUsers as List<UserEntity>)
        //     .sort((a, b) => b.time.compareTo(a.time));

        var suggestions = churchUsers as List<UserEntity>;
        suggestions.addAll(publicFigures);
        suggestions.addAll(cityUsers);
        suggestions.addAll(newestUsers);

        suggestions.removeWhere((s) => s.uid == loginState.uid);
        suggestions.removeWhere((s) => loginState.connections.contains(s.id));

        suggestions.toSet().toList();

        var reqs = requests as List<UserEntity>;
        reqs.removeWhere((r) => loginState.connections.contains(r.id));

        suggestions.removeWhere((s) => reqs.map((r) => r.id).contains(s.id));

        return _kInitialExploreState.copyWith(
          connectionItems: _userEntitiesToSuggestions(suggestions,
                  loginState.sentRequests ?? [], loginState.mutedChats ?? [])
              .toSet()
              .toList(),
          postItems: _postEntitiesToItems(filiteredPosts),
          requestItems: _userEntitiesToRequests(requests),
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

  static List<ConnectionItem> _userEntitiesToSuggestions(
    List<UserEntity> entities,
    List<String> requests,
    List<String> muted,
  ) {
    print('muted=${muted.length}');
    return entities
        .map((entity) {
          return ConnectionItem(
            id: entity.id,
            city: entity.city ?? "None",
            church: entity.churchInfo != null
                ? entity.churchInfo.churchName
                : "None",
            isChurch: entity.isChurch ?? false,
            image: entity.image,
            name: entity.isChurch ? entity.churchName : entity.fullName,
            denomination: entity.churchInfo != null
                ? entity.churchInfo.churchDenomination
                : "None",
            requested: (requests ?? []).contains(entity.id),
          );
        })
        .where((r) => !muted.contains(r.id))
        .toList();
  }

  static List<ConnectionItem> _userEntitiesToRequests(
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
        name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
        denomination: entity.churchInfo != null
            ? entity.churchInfo.churchDenomination
            : "None",
        requested: false,
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
    if (loginState is LoggedInUser &&
        !loginState.sentRequests.contains(connection.id)) {
      try {
        requestRepository.addRequest(
          image: loginState.image,
          toName: connection.name,
          toId: connection.id,
          fromName: loginState.fullName,
          fromId: loginState.uid,
          token: loginState.token,
        );
        yield ConnectionAddedSuccess();
      } catch (e) {
        yield ConnectionAddedError(e);
      }
    }
  }

  static Stream<ExploreMessage> saveAcceptConnection(
    FirestoreRequestRepository requestRepository,
    ConnectionItem connection,
    LoginState loginState,
  ) async* {
    print('[DEBUG] ExploreBloc#saveAcceptConnection');
    if (loginState is LoggedInUser) {
      try {
        await requestRepository.acceptRequest(
          image: loginState.image,
          toName: connection.name,
          toId: connection.id,
          fromName: loginState.fullName,
          fromId: loginState.uid,
          token: loginState.token,
        );
        yield ConnectionAddedSuccess();
      } catch (e) {
        yield ConnectionAddedError(e);
      }
    }
  }

  static Stream<ExploreMessage> saveDeclineConnection(
    FirestoreRequestRepository requestRepository,
    ConnectionItem connection,
    LoginState loginState,
  ) async* {
    print('[DEBUG] ExploreBloc#saveDeclineConnection');
    if (loginState is LoggedInUser) {
      try {
        await requestRepository.declineRequest(
          image: loginState.image,
          toName: connection.name,
          toId: connection.id,
          fromName: loginState.fullName,
          fromId: loginState.uid,
          token: loginState.token,
        );
        yield ConnectionAddedSuccess();
      } catch (e) {
        yield ConnectionAddedError(e);
      }
    }
  }
}
