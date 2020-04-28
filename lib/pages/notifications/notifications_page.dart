import 'dart:async';
import 'dart:ui';

import '../../util/asset_utils.dart';
import '../../widgets/curved_scaffold.dart';
import '../../widgets/empty_list_view.dart';
import './widgets/notifications_list_item.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).notifications_title
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: StreamBuilder<NotificationsListState>(
          stream: _notificationsBloc.notificationsListState$,
          initialData: _notificationsBloc.notificationsListState$.value,
          builder: (context, snapshot) {
            var data = snapshot.data;
            print(snapshot.data);

            if (data.error != null) {
              print(data.error);
              return Center(
                child: Text(
                  S.of(context).error_occurred,
                ),
              );
            }

            if (data.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (data.notificationItems.isEmpty) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 150,
                child: Center(
                  child: EmptyListView(
                    title: S.of(context).notifications_empty_title,
                    description: S.of(context).notifications_empty_desc,
                    icon: Icons.notifications,
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: data.notificationItems.length,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return NotificationsListItem(
                  notificationItem: data.notificationItems[index],
                );
              },
              separatorBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Divider(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}