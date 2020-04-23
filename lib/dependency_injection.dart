import './data/post/firestore_post_repository.dart';
import './data/user/firestore_user_repository.dart';
import './data/room/firestore_room_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Injector extends InheritedWidget {
  final FirestoreUserRepository userRepository;
  final FirestorePostRepository postRepository;
  final FirestoreRoomRepository roomRepository;

  Injector({
    Key key,
    @required this.userRepository,
    @required this.postRepository,
    @required this.roomRepository,
    @required Widget child,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType(aspect: Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) =>
    userRepository != oldWidget.userRepository &&
    postRepository != oldWidget.postRepository &&
    roomRepository != oldWidget.roomRepository;
}