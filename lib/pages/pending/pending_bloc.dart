import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../bloc/bloc_provider.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './pending_state.dart';

const _kInitialPendingState = PendingState(
  isLoading: true,
  error: null,
  pending: [],
);

class PendingBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function(bool) approveUser;
  Function(Tuple3<String, String, String>) completeApproval;

  ///
  /// Output streams
  ///
  final ValueStream<PendingState> pendingState$;
  final Stream<PendingApprovalMessage> message$;
  final ValueStream<bool> isLoading$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  PendingBloc._({
    @required this.approveUser,
    @required this.completeApproval,
    @required this.pendingState$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory PendingBloc({
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controllers
    ///
    final approveUser = PublishSubject<Tuple3<String, String, String>>();
    final approveSubject = BehaviorSubject<bool>.seeded(false);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final message$ = approveUser.exhaustMap((userInfo) {
      return saveApproval(
        userBloc,
        userRepository,
        userInfo.item1,
        userInfo.item2,
        userInfo.item3,
        approveSubject.value,
        isLoadingSubject,
      );
    }).publish();

    final pendingState$ = _getPending(
      userBloc,
      userRepository,
    ).publishValueSeeded(_kInitialPendingState);

    final subscriptions = <StreamSubscription>[
      pendingState$.connect(),
      message$.connect(),
    ];

    return PendingBloc._(
        completeApproval: approveUser.add,
        approveUser: approveSubject.add,
        isLoading$: isLoadingSubject,
        message$: message$,
        pendingState$: pendingState$,
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
  }

  @override
  void dispose() => _dispose();

  static Stream<PendingState> _toState(
    LoginState loginState,
    FirestoreUserRepository userRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialPendingState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository
          .getPending()
          .map((entities) {
            if (entities.length > 0) {
              return _entitiesToPendingItems(entities);
            } else {
              return List<PendingItem>();
            }
          })
          .map((pendingItems) {
            return _kInitialPendingState.copyWith(
              isLoading: false,
              pending: pendingItems,
            );
          })
          .startWith(_kInitialPendingState)
          .onErrorReturnWith((e) {
            return _kInitialPendingState.copyWith(
              isLoading: false,
              error: e,
            );
          });
    }

    return Stream.value(
      _kInitialPendingState.copyWith(
        isLoading: false,
        error: 'Dont know loginState=$loginState',
      ),
    );
  }

  static List<PendingItem> _entitiesToPendingItems(
    List<UserEntity> entities,
  ) {
    return entities.map((entity) {
      return PendingItem(
        id: entity.id,
        image: entity.image ?? '',
        isChurch: entity.isChurch ?? false,
        name: (entity.isChurch ?? false)
            ? entity.churchName
            : '${entity.firstName} ${entity.lastName}',
        denomination: entity.churchDenomination ?? '',
        churchAddress: entity.churchAddress ?? '',
        city: entity.city ?? '',
        churchName: entity.churchName ?? '',
        token: entity.pushNotificationToken,
      );
    }).toList();
  }

  static Stream<PendingState> _getPending(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        userRepository,
      );
    });
  }

  static Stream<PendingApprovalMessage> saveApproval(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
    String userId,
    String userToken,
    String userImage,
    bool approved,
    Sink<bool> isLoading,
  ) async* {
    print('[DEBUG] PendingBloc#saveApproval');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoading.add(true);
        await userRepository.saveApproval(
          userId,
          approved,
          userToken,
          userImage,
        );
        yield PendingApprovalSuccess();
      } catch (e) {
        yield PendingApprovalError(e);
      } finally {
        isLoading.add(false);
      }
    }
  }
}
