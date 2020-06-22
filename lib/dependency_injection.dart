import './data/notification/firestore_notification_repository.dart';
import './data/post/firestore_post_repository.dart';
import './data/user/firestore_user_repository.dart';
import './data/room/firestore_room_repository.dart';
import './data/event/firestore_event_repository.dart';
import './data/chat/firestore_chat_repository.dart';
import './data/group/firestore_group_repository.dart';
import './data/comment/firestore_comment_repository.dart';
import './data/request/firestore_request_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Injector extends InheritedWidget {
  final FirestoreUserRepository userRepository;
  final FirestorePostRepository postRepository;
  final FirestoreRoomRepository roomRepository;
  final FirestoreNotificationRepository notificationRepository;
  final FirestoreEventRepository eventRepository;
  final FirestoreChatRepository chatRepository;
  final FirestoreGroupRepository groupRepository;
  final FirestoreCommentRepository commentRepository;
  final FirestoreRequestRepository requestRepository;

  Injector({
    Key key,
    @required this.userRepository,
    @required this.postRepository,
    @required this.roomRepository,
    @required this.notificationRepository,
    @required this.eventRepository,
    @required this.chatRepository,
    @required this.groupRepository,
    @required this.commentRepository,
    @required this.requestRepository,
    @required Widget child,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType(aspect: Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) =>
    userRepository != oldWidget.userRepository &&
    postRepository != oldWidget.postRepository &&
    roomRepository != oldWidget.roomRepository &&
    notificationRepository != oldWidget.notificationRepository &&
    eventRepository != oldWidget.eventRepository &&
    chatRepository != oldWidget.chatRepository &&
    groupRepository != oldWidget.groupRepository &&
    commentRepository != oldWidget.commentRepository &&
    requestRepository != oldWidget.requestRepository;
}