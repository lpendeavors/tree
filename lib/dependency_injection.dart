import './data/user/firestore_user_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Injector extends InheritedWidget {
  final FirebaseUserRepository userRepository;

  Injector({
    Key key,
    @required this.userRepository,
    @required Widget child,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType(aspect: Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) =>
      userRepository != oldWidget.userRepository;
}