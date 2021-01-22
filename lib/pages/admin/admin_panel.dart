import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:treeapp/pages/events/events_state.dart';
import 'package:treeapp/util/asset_utils.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './admin_bloc.dart';
import './admin_state.dart';

class AdminPanel extends StatefulWidget {
  final UserBloc userBloc;

  const AdminPanel({
    Key key,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(25, 45, 25, 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(width: 15),
                          Image.asset(
                            ic_launcher,
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              'TREE',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 0.5,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    Container(
                      color: Colors.white,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: (MediaQuery.of(context).size.height / 2) +
                              (MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? 0
                                  : (MediaQuery.of(context).size.height / 5)),
                        ),
                        child: Scrollbar(
                          child: ListView(
                            padding: EdgeInsets.all(16),
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  widget.userBloc.signOut.add(null);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/events',
                                      arguments: EventFilter.pending);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Pending Events',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/events',
                                      arguments: EventFilter.inactive);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Inactive Events',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/events',
                                      arguments: EventFilter.completed);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Completed Events',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/pending');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Pending Main',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/reports',
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Reports',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Count Signups',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Advert CPR',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Toggle Post Visibility',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Min Ad Budget',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Feed Ad Spacing',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Create Ad',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'All Ads',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Send Broadcast',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'About Link',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Privacy Link',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Terms Link',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Package Name',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Support Email',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Show Version',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Update Version',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Add Admin User',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Google Map Key',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Stripe Api Key',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  print('ok');
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  width: double.infinity,
                                  child: Text(
                                    'Remove Admin User',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
