import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../data/chat/firestore_chat_repository.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/user_entity.dart';
import './create_message_state.dart';

bool _isMembersValid(List<MemberItem> members) {
  return members.length > 1;
}

const _kInitialCreateMessageState = CreateMessageState(
  error: null,
  isLoading: true,
  myConnections: [],
);

class CreateMessageBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() submitCreateMessage;
  final void Function(int) typeChanged;
  final void Function(List<MemberItem>) membersChanged;
  final void Function(MemberItem) toggleMember;

  ///
  /// Output streams
  ///
  final ValueStream<CreateMessageState> createMessageState$;
  final Stream<MessageCreateMessage> message$;
  final ValueStream<bool> isLoading$;

  final ValueStream<int> type$;
  final ValueStream<List<MemberItem>> members$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  CreateMessageBloc._({
    @required this.submitCreateMessage,
    @required this.toggleMember,
    @required this.membersChanged,
    @required this.typeChanged,
    @required this.members$,
    @required this.type$,
    @required this.createMessageState$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory CreateMessageBloc({
    int type,
    @required UserBloc userBloc,
    @required FirestoreChatRepository chatRepository,
    @required FirestoreGroupRepository groupRepository,
    @required FirestoreUserRepository userRepository,
  }) {
    ///
    /// Assert
    ///
    assert(type != null, 'type cannot be null');
    assert(userBloc != null, 'userBloc cannot be null');
    assert(chatRepository != null, 'chatRepository cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Stream controller
    ///
    final typeSubject = BehaviorSubject<int>.seeded(type);
    final membersSubject = BehaviorSubject<List<MemberItem>>.seeded([]);
    final submitCreateMessageSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final membersError$ = membersSubject.map((members) {
      if (_isMembersValid(members)) return null;
      return const MembersError();
    }).share();

    final allFieldsAreValid$ = Rx.combineLatest(
      [
        membersError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = submitCreateMessageSubject
        .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
        .where((isValid) => isValid)
        .exhaustMap(
          (_) => performSave(
            userBloc,
            groupRepository,
            chatRepository,
            membersSubject.value,
            MessageType.values[type],
          ),
        )
        .publish();

    final createMessageState$ = _getConnectionsList(
      userBloc,
      groupRepository,
      chatRepository,
      userRepository,
      MessageType.values[type],
    ).publishValueSeeded(_kInitialCreateMessageState);

    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      createMessageState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      membersSubject,
      isLoadingSubject,
    ];

    return CreateMessageBloc._(
        membersChanged: membersSubject.add,
        members$: membersSubject.stream,
        typeChanged: typeSubject.add,
        type$: typeSubject.stream,
        createMessageState$: createMessageState$,
        isLoading$: isLoadingSubject,
        message$: message$,
        submitCreateMessage: () => submitCreateMessageSubject.add(null),
        toggleMember: (member) {
          var members = membersSubject.value;
          members.contains(member)
              ? members.remove(member)
              : members.add(member);
          membersSubject.add(members);
        },
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
          await Future.wait(controllers.map((c) => c.close()));
        });
  }

  static Stream<CreateMessageState> _toState(
    LoginState loginState,
    FirestoreGroupRepository groupRepository,
    FirestoreChatRepository chatRepository,
    FirestoreUserRepository userRepository,
    MessageType type,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialCreateMessageState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository
          .getMyConnections(loginState.connections)
          .map((entities) {
            return _entitiesToConnectionItems(entities);
          })
          .map((connectionItems) {
            return _kInitialCreateMessageState.copyWith(
              myConnections: connectionItems,
              isLoading: false,
            );
          })
          .startWith(_kInitialCreateMessageState)
          .onErrorReturnWith((e) {
            return _kInitialCreateMessageState.copyWith(
              error: e,
              isLoading: false,
            );
          });
    }

    return Stream.value(
      _kInitialCreateMessageState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static List<ConnectionItem> _entitiesToConnectionItems(
    List<UserEntity> entities,
  ) {
    return entities.map((entity) {
      return ConnectionItem(
        id: entity.documentId,
        name: entity.fullName,
        about: entity.aboutMe ?? "I am new to tree",
        image: entity.image ?? "",
      );
    }).toList();
  }

  static Stream<CreateMessageState> _getConnectionsList(
      UserBloc userBloc,
      FirestoreGroupRepository groupRepository,
      FirestoreChatRepository chatRepository,
      FirestoreUserRepository userRepository,
      MessageType type) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        groupRepository,
        chatRepository,
        userRepository,
        type,
      );
    });
  }

  static Stream<MessageCreateMessage> performSave(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    FirestoreChatRepository chatRepository,
    List<MemberItem> members,
    MessageType type,
  ) async* {
    print('[DEBUG] CreateMessageBloc#performSave');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        var details = await groupRepository.save(
          null,
          members,
          true, //  isPrivate
          true, //  isGroup
          false, // isRoom
          true, //  isConversation
          loginState.uid,
          loginState.isAdmin,
          loginState.isVerified,
          "",
        );
        yield MessageCreateSuccess(details);
      } catch (e) {
        yield MessageCreateError(e);
      }
    } else {
      yield MessageCreateError(NotLoggedInError());
    }
  }
}
