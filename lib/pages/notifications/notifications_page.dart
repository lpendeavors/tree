import 'dart:async';
import 'dart:ui';

import '../../util/asset_utils.dart';
import '../../widgets/curved_scaffold.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './notifications_bloc.dart';
import './notifications_state.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final NotificationsBloc notificationsBloc;
  final UserBloc userBloc;

  const NotificationsPage({
    Key key,
    @required this.userBloc,
    @required this.notificationsBloc,
  }) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<StreamSubscription> _subscriptions;
  NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();

    _notificationsBloc = widget.notificationsBloc;
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _notificationsBloc.dispose();
    print('_NotificationsPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
    );
  }
}