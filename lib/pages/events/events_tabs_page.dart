import 'dart:async';

import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './widgets/events_map.dart';
import './widgets/events_list.dart';
import './events_bloc.dart';
import 'package:flutter/material.dart';

class EventsTabsPage extends StatefulWidget {
  final EventsBloc eventsBloc;
  final UserBloc userBloc;

  const EventsTabsPage({
    Key key,
    @required this.userBloc,
    @required this.eventsBloc,
  }) : super(key: key);

  @override
  _EventsTabsPageState createState() => _EventsTabsPageState();
}

class _EventsTabsPageState extends State<EventsTabsPage> {
  List<StreamSubscription> _subscriptions;
  EventsBloc _eventsBloc;

  PageController _controller = PageController();
  ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _eventsBloc = widget.eventsBloc;
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _eventsBloc.dispose();
    print('[DEBUG] _EventsTabsPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Flexible(
                    child: RaisedButton(
                      onPressed: () async {
                        
                      },
                      color: Colors.grey[50],
                      elevation: 0,
                      padding: EdgeInsets.only(top: 12, bottom: 12, right: 10, left: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.search,
                            size: 15,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            S.of(context).events_search_hint,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottom: _tabNavigation(),
      ),
      body: _tabs(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () => Navigator.of(context).pushNamed('/event_types'),
      ),
    );
  }

  Widget _tabNavigation() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40),
      child: Container(
        height: 40,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor,
        ),
        child: ValueListenableBuilder(
          valueListenable: _currentPage,
          builder: (context, value, child) {
            return Row(
              children: <Widget>[
                _tabItem(
                  index: 0,
                  label: S.of(context).events_tab_explore,
                  onTap: () => _changePage(0),
                ),
                _tabItem(
                  index: 1,
                  label: S.of(context).events_tab_map,
                  onTap: () => _changePage(1),
                ),
                _tabItem(
                  index: 2,
                  label: S.of(context).events_tab_mine,
                  onTap: () => _changePage(2),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tabs() {
    return PageView(
      controller: _controller,
      onPageChanged: (page) => _currentPage.value = page,
      children: <Widget>[
        EventsList(
          bloc: _eventsBloc,
        ),
        EventsMap(
          bloc: _eventsBloc,
        ),
        EventsList(
          bloc: _eventsBloc,
          onlyMine: true,
        ),
      ],
    );
  }

  void _changePage(int page) {
    _currentPage.value = page;
    _controller.animateToPage(
      page,
      duration: Duration(milliseconds: 5),
      curve: Curves.easeOutSine,
    );
  }

  Widget _tabItem({
    Function() onTap,
    String label,
    int index,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          child: Center(
            child: Text(
              label,
              style: _tabTextStyle(index),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: index == _currentPage.value
              ? Colors.white
              : Colors.transparent,
          ),
        ),
      ),
    );
  }

  TextStyle _tabTextStyle(int index) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: index == _currentPage.value
        ? Theme.of(context).primaryColor
        : Colors.white.withOpacity(0.7),
    );
  }
}