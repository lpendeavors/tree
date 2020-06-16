import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/group/firestore_group_repository.dart';
import '../create_message/create_message_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/user_entity.dart';
import './create_group_state.dart';

class CreateGroupBloc implements BaseBloc {
  ///
  /// Input functions
  /// 
  final void Function() saveGroup;
  final void Function(String) groupNameChanged;
  final void Function(String) groupImageChanged;
  final void Function(String) groupDescriptionChanged;
  final void Function(bool) groupIsPrivateChanged;

  /// 
  /// Output streams
  /// 
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
    @required this.groupImage$,
    @required this.groupPrivate$,
    @required this.groupMembers$,
    @required this.groupNameChanged,
    @required this.groupDescriptionChanged,
    @required this.groupImageChanged,
    @required this.groupIsPrivateChanged,
    @required this.saveGroup,
    @required this.isLoading$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory CreateGroupBloc({
    List<MemberItem> members,
    FirestoreGroupRepository groupRepository,
  }) {
    /// 
    /// Assert
    /// 
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(members != null, 'members cannot be null');

    /// 
    /// Stream controllers
    /// 
    final groupNameSubject = BehaviorSubject<String>.seeded('');
    final groupDescriptionSubject = BehaviorSubject<String>.seeded('');
    final groupImageSubject = BehaviorSubject<String>.seeded('');
    final groupIsPrivateSubject = BehaviorSubject<bool>.seeded(false);
    final groupMembersSubject = BehaviorSubject<List<MemberItem>>.seeded(members);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final saveGroupSubject = PublishSubject<void>();

    /// 
    /// Streams
    /// 
    
    final allFieldsValid$ = Rx.combineLatest(
      [

      ],
      (allErrors) => allErrors.every((error) {
        print(error);
        return error == null;
      })
    );

    final message$ = saveGroupSubject
      .withLatestFrom(allFieldsValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => performSave(

        ),
      ).publish();

    final subscriptions = <StreamSubscription>[
      message$.connect(),
    ];

    final controllers = <StreamController>[
      groupNameSubject,
      groupDescriptionSubject,
      groupImageSubject,
      groupIsPrivateSubject,
      groupMembersSubject,
    ];

    return CreateGroupBloc._(
      groupNameChanged: groupNameSubject.add,
      groupDescriptionChanged: groupDescriptionSubject.add,
      groupImageChanged: groupImageSubject.add,
      groupIsPrivateChanged: groupIsPrivateSubject.add,
      groupImage$: groupImageSubject.stream,
      groupPrivate$: groupIsPrivateSubject.stream,
      groupMembers$: groupMembersSubject.stream,
      message$: message$,
      isLoading$: isLoadingSubject,
      saveGroup: () => saveGroupSubject.add(null),
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  static Stream<GroupCreateMessage> performSave(

  ) async* {
    try {
      
    } catch (e) {
      yield GroupCreateError(e);
    }
  }
}