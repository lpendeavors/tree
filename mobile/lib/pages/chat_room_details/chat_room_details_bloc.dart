import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:treeapp/models/old/shared_post.dart';
import 'package:treeapp/pages/feed/feed_state.dart' as feed;
import 'package:treeapp/util/post_utils.dart';
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
  final void Function() deleteGroup;
  final void Function() suspendGroup;
  final void Function() muteGroup;
  final void Function(String) leaveGroup;
  final void Function(String) makeAdmin;

  ///
  /// Output streams
  ///
  final ValueStream<ChatRoomDetailsState> chatRoomDetailsState$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ChatRoomDetailsBloc._({
    @required this.deleteGroup,
    @required this.suspendGroup,
    @required this.muteGroup,
    @required this.leaveGroup,
    @required this.makeAdmin,
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
        deleteGroup: () =>
            _performDelete(groupRepository, userBloc, roomId, true),
        suspendGroup: () =>
            _performDelete(groupRepository, userBloc, roomId, false),
        muteGroup: () => userBloc.mute(roomId),
        leaveGroup: (userId) =>
            _leaveGroup(groupRepository, userBloc, userId, roomId),
        makeAdmin: (userId) =>
            _makeAdmin(groupRepository, userBloc, userId, roomId),
        dispose: () async {
          await Future.wait(subscriptions.map((s) => s.cancel()));
        });
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
      return Rx.combineLatest2(groupRepository.getById(groupId: roomId),
          postRepository.getByGroup(roomId), (group, posts) {
        return _kInitialChatRoomDetailsState.copyWith(
          chatRoomDetails: _entityToRoomDetailsItem(group, loginState.uid),
          chatRoomPosts: _entitiesToRoomPostItems(
              posts, loginState.uid, loginState.mutedChats),
          isLoading: false,
        );
      }).startWith(_kInitialChatRoomDetailsState).onErrorReturnWith((e) {
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
      isAdmin: _getIsChatAdmin(entity.groupMembers, uid),
      description: entity.groupDescription ?? "Hey I'm new to Tree",
      wallEnabled: entity.canPostOnWall ?? false,
    );
  }

  static List<feed.FeedItem> _entitiesToRoomPostItems(
    List<PostEntity> posts,
    String uid,
    List<String> muted,
  ) {
    return posts.map((entity) {
      return feed.FeedItem(
        id: entity.documentId,
        tags: entity.tags,
        timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
        timePostedString:
            timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
        message: entity.postMessage,
        name: entity.fullName != null ? entity.fullName : entity.churchName,
        userImage: entity.image ?? "",
        isPoll: entity.type == feed.PostType.poll.index,
        postImages: _getPostImages(entity),
        userId: entity.ownerId,
        isLiked: (entity.likes ?? []).contains(uid),
        isMine: entity.ownerId == uid,
        abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
        isShared: entity.isPostPrivate == 1,
        pollData: entity.pollData ?? [],
        type: (entity.postData != null && entity.postData.isNotEmpty)
            ? entity.postData[0].type ?? 0
            : 0,
        likes: entity.likes ?? [],
        sharedPost: entity.sharedPost != null
            ? _entitiyToSharedItem(entity.sharedPost, uid, muted)
            : null,
      );
    }).toList();
  }

  static feed.FeedItem _entitiyToSharedItem(
    SharedPost entity,
    String uid,
    List<String> muted,
  ) {
    return feed.FeedItem(
      id: null,
      tags: entity.tags,
      timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
      timePostedString:
          timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
      message: entity.postMessage,
      name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
      userImage: entity.image,
      userId: entity.ownerId,
      isPoll: entity.type == PostType.poll.index,
      postImages: _getSharedImages(entity),
      isMine: entity.ownerId == uid,
      isLiked: entity.likes != null ? entity.likes.contains(uid) : false,
      abbreviatedPost: getAbbreviatedPost(entity.postMessage ?? ""),
      isShared: entity.isShared ?? false,
      pollData: entity.pollData ?? [],
      likes: entity.likes ?? [],
      sharedPost: null,
      type: (entity.postData != null && entity.postData.isNotEmpty)
          ? entity.postData[0].type ?? 0
          : 0,
    );
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

  static bool _getIsChatAdmin(
    List<GroupMember> members,
    String uid,
  ) {
    if (members.map((m) => m.uid).contains(uid)) {
      var me = members.where((m) => m.uid == uid).first;
      return me.groupAdmin ?? false;
    }
    return false;
  }

  static List<ChatRoomMemberItem> _entitiesToRoomMemberItem(
    List<GroupMember> members,
  ) {
    return members.map((member) {
      return ChatRoomMemberItem(
        id: member.uid,
        image: member.image,
        name: member.fullName,
        isAdmin: member.groupAdmin,
      );
    }).toList();
  }

  static List<String> _getPostImages(PostEntity entity) {
    List<String> images = List<String>();

    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        images = entity.postData.map((data) => data.imageUrl).toList();
      }
    }

    return images;
  }

  static List<String> _getSharedImages(SharedPost entity) {
    List<String> images = List<String>();

    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        images = entity.postData.map((data) => data.imageUrl).toList();
      }
    }

    return images;
  }

  static Future<void> _performDelete(
    FirestoreGroupRepository groupRepository,
    UserBloc userBloc,
    String roomId,
    bool delete,
  ) async {
    print('[DEBUG] ChatRoomDetailsBloc#performDelete');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      await groupRepository.delete(roomId, delete);
    }
  }

  static Future<void> _leaveGroup(
    FirestoreGroupRepository groupRepository,
    UserBloc userBloc,
    String userId,
    String roomId,
  ) async {
    print('[DEBUG] ChatRoomDetailsBloc#leaveGroup');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      await groupRepository.leave(
        roomId,
        userId,
      );
    }
  }

  static Future<void> _makeAdmin(
    FirestoreGroupRepository groupRepository,
    UserBloc userBloc,
    String userId,
    String roomId,
  ) async {
    print('[DEBUG] ChatRoomDetailsBloc#makeAdmin');
    var loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      await groupRepository.makeAdmin(
        roomId,
        userId,
      );
    }
  }
}
