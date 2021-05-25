import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/old/group_entity.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/user_entity.dart';
import './create_group_state.dart';

const _kInitialGroupCreateState = GroupCreateState(
  error: null,
  groupItem: null,
  isLoading: true,
);

class CreateGroupBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() saveGroup;
  final void Function(String) groupNameChanged;
  final void Function(String) groupImageChanged;
  final void Function(String) groupDescriptionChanged;
  final void Function(bool) groupIsPrivateChanged;
  final void Function(bool) mediaUpdated;

  ///
  /// Output streams
  ///
  final ValueStream<GroupCreateState> groupCreateState$;
  final ValueStream<String> groupImage$;
  final ValueStream<bool> groupPrivate$;
  final ValueStream<List<MemberItem>> groupMembers$;
  final ValueStream<bool> isLoading$;
  final Stream<GroupCreateMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  CreateGroupBloc._({
    @required this.groupCreateState$,
    @required this.groupImage$,
    @required this.groupPrivate$,
    @required this.groupMembers$,
    @required this.groupNameChanged,
    @required this.groupDescriptionChanged,
    @required this.groupImageChanged,
    @required this.groupIsPrivateChanged,
    @required this.mediaUpdated,
    @required this.saveGroup,
    @required this.isLoading$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory CreateGroupBloc({
    String groupId,
    @required UserBloc userBloc,
    @required List<MemberItem> members,
    @required FirestoreGroupRepository groupRepository,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(members != null, 'members cannot be null');

    ///
    /// Stream controllers
    ///
    final mediaUpdatedSubject = BehaviorSubject<bool>.seeded(false);
    final groupNameSubject = BehaviorSubject<String>.seeded('');
    final groupDescriptionSubject = BehaviorSubject<String>.seeded('');
    final groupImageSubject = BehaviorSubject<String>.seeded('');
    final groupIsPrivateSubject = BehaviorSubject<bool>.seeded(false);
    final groupMembersSubject =
        BehaviorSubject<List<MemberItem>>.seeded(members);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final saveGroupSubject = PublishSubject<void>();

    ///
    /// Streams
    ///

    final allFieldsValid$ = Rx.combineLatest(
      [],
      (allErrors) => allErrors.every(
        (error) {
          print(error);
          return error == null;
        },
      ),
    );

    final message$ = saveGroupSubject
        // .withLatestFrom(allFieldsValid$, (_, bool isValid) => isValid)
        // .where((isValid) => isValid)
        .exhaustMap(
          (_) => performSave(
            userBloc,
            groupRepository,
            groupNameSubject.value,
            groupImageSubject.value,
            groupDescriptionSubject.value,
            groupMembersSubject.value,
            groupId,
            mediaUpdatedSubject.value,
            groupIsPrivateSubject.value,
            isLoadingSubject,
          ),
        )
        .publish();

    final groupCreateState$ = _getGroupDetails(
      userBloc,
      groupRepository,
      groupId,
    ).publishValueSeeded(_kInitialGroupCreateState);

    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      groupCreateState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      groupNameSubject,
      groupDescriptionSubject,
      groupImageSubject,
      groupIsPrivateSubject,
      groupMembersSubject,
      mediaUpdatedSubject,
    ];

    return CreateGroupBloc._(
      mediaUpdated: mediaUpdatedSubject.add,
      groupNameChanged: groupNameSubject.add,
      groupDescriptionChanged: groupDescriptionSubject.add,
      groupImageChanged: groupImageSubject.add,
      groupIsPrivateChanged: groupIsPrivateSubject.add,
      groupImage$: groupImageSubject.stream,
      groupPrivate$: groupIsPrivateSubject.stream,
      groupMembers$: groupMembersSubject.stream,
      groupCreateState$: groupCreateState$,
      message$: message$,
      isLoading$: isLoadingSubject,
      saveGroup: () => saveGroupSubject.add(null),
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
    );
  }

  static Stream<GroupCreateState> _toState(
    LoginState loginState,
    FirestoreGroupRepository groupRepository,
    String groupId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialGroupCreateState.copyWith(
          error: "NotLoggedIn",
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (groupId != null) {
        return groupRepository
            .getById(groupId: groupId)
            .map((entity) {
              return _entityToGroupItem(entity);
            })
            .map((groupItem) {
              return _kInitialGroupCreateState.copyWith(
                groupItem: groupItem,
                isLoading: false,
              );
            })
            .startWith(_kInitialGroupCreateState)
            .onErrorReturnWith((e) {
              return _kInitialGroupCreateState.copyWith(
                error: e,
                isLoading: false,
              );
            });
      } else {
        return Stream.value(
          _kInitialGroupCreateState.copyWith(
            isLoading: false,
          ),
        );
      }
    }

    return Stream.value(
      _kInitialGroupCreateState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static GroupItem _entityToGroupItem(
    GroupEntity entity,
  ) {
    return GroupItem(
      id: entity.id,
      name: entity.groupName,
      image: entity.groupImage,
      description: entity.groupDescription,
      isPublic: entity.isGroupPrivate ?? false,
    );
  }

  static Stream<GroupCreateState> _getGroupDetails(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    String groupId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        groupRepository,
        groupId,
      );
    });
  }

  static Stream<GroupCreateMessage> performSave(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    String name,
    String image,
    String description,
    List<MemberItem> members,
    String groupId,
    bool mediaUpdated,
    bool isPrivate,
    Sink<bool> isLoadingSubject,
  ) async* {
    print('[DEBUG] CreateGroupBloc#performSave');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoadingSubject.add(true);
        var details = await groupRepository.save(
          groupId,
          members,
          isPrivate, //  isPrivate
          true, //  isGroup
          false, // isRoom
          false, //  isConversation
          loginState.uid,
          loginState.isAdmin,
          loginState.isVerified,
          name,
          image,
          description,
          mediaUpdated,
        );
        yield GroupCreateSuccess(details);
      } catch (e) {
        yield GroupCreateError(e);
      } finally {
        isLoadingSubject.add(false);
      }
    } else {
      yield GroupCreateError("Not logged in");
    }
  }
}
