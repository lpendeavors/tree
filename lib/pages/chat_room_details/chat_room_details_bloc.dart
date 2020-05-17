import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../models/old/group_entity.dart';
import '../../models/old/group_member.dart';
import '../../models/old/post_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './chat_room_details_state.dart';

const _kInitialChatRoomDetailsState = ChatRoomDetailsState(
  chatRoomDetails: null,
  chatRoomPosts: [],
  isLoading: true,
  error: null,
);

class ChatRoomDetailsBloc implements BaseBloc {
  /// 
  /// Input functions
  ///
  

  /// 
  /// Output streams
  ///
  final ValueStream<ChatRoomDetailsState> chatRoomDetailsState$;
  
  /// 
  /// Clean up
  ///
  final void Function() _dispose;

  ChatRoomDetailsBloc._({
    @required this.chatRoomDetailsState$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ChatRoomDetailsBloc({
    @required UserBloc userBloc,
    @required FirestoreGroupRepository groupRepository,
    @required FirestorePostRepository postRepository,
    @required String roomId,
  }) {
    /// 
    /// Assert
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(postRepository != null, 'postRepository cannot by null');
    assert(roomId != null, 'roomId cannot be null');

    /// 
    /// Stream controllers
    ///
    

    /// 
    /// Streams 
    ///
    final chatRoomDetailsState$ = _getRoomDetails(
      userBloc,
      groupRepository,
      postRepository,
      roomId,
    ).publishValueSeeded(_kInitialChatRoomDetailsState);

    final subscriptions = <StreamSubscription>[
      chatRoomDetailsState$.connect(),
    ];

    return ChatRoomDetailsBloc._(
      chatRoomDetailsState$: chatRoomDetailsState$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Stream<ChatRoomDetailsState> _toState(
    LoginState loginState,
    FirestoreGroupRepository groupRepository,
    FirestorePostRepository postRepository,
    String roomId,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialChatRoomDetailsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(
          groupRepository.getById(groupId: roomId),
          postRepository.getByGroup(roomId),
          (group, posts) {
            return _kInitialChatRoomDetailsState.copyWith(
              chatRoomDetails: _entityToRoomDetailsItem(group, loginState.uid),
              chatRoomPosts: _entitiesToRoomPostItems(posts),
              isLoading: false,
            );
          }
        )
        .startWith(_kInitialChatRoomDetailsState)
        .onErrorReturnWith((e) {
          return _kInitialChatRoomDetailsState.copyWith(
            error: e,
            isLoading: false,
          );
        });
    }

    return Stream.value(
      _kInitialChatRoomDetailsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static ChatRoomDetailsItem _entityToRoomDetailsItem(
    GroupEntity entity,
    String uid,
  ) {
    return ChatRoomDetailsItem(
      id: entity.documentId,
      name: entity.groupName,
      isGroup: entity.isGroup ?? false,
      isConversation: entity.isConversation ?? false,
      image: entity.groupImage,
      members: _entitiesToRoomMemberItem(entity.groupMembers),
      isAdmin: _checkIfAdmin(entity.groupMembers, uid),
      description: entity.groupDescription,
      wallEnabled: entity.canPostOnWall ?? false,
    );
  }

  static List<ChatRoomPostItem> _entitiesToRoomPostItems(
    List<PostEntity> posts,
  ) {
    return posts.map((post) {
      return ChatRoomPostItem(
        id: post.documentId,
      );
    }).toList();
  }

  static Stream<ChatRoomDetailsState> _getRoomDetails(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    FirestorePostRepository postRepository,
    String roomId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        groupRepository,
        postRepository,
        roomId,
      );
    });
  }

  static List<ChatRoomMemberItem> _entitiesToRoomMemberItem(
    List<GroupMember> members,
  ) {
    return members.map((member) {
      return ChatRoomMemberItem(
        id: member.uid,
        image: member.image,
      );
    }).toList();
  }

  static bool _checkIfAdmin(
    List<GroupMember> members,
    String userId,
  ) {
    var admin = false;
    members.forEach((member) {
      if (member.uid == userId && member.groupAdmin) {
        admin = true;
      }
    });
    return admin;
  }
}