import 'dart:async';

import '../../pages/explore/widgets/explore_posts_tab.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './widgets/explore_connections_tab.dart';
import './explore_bloc.dart';
import './explore_state.dart';
import 'package:flutter/material.dart';

class ExploreTabsPage extends StatefulWidget {
  final UserBloc userBloc;
  final ExploreBloc exploreBloc;

  const ExploreTabsPage({
    Key key,
    @required this.userBloc,
    @required this.exploreBloc,
  }) : super(key: key);

  @override
  _ExploreTabsPageState createState() => _ExploreTabsPageState();
}

class _ExploreTabsPageState extends State<ExploreTabsPage> {
  List<StreamSubscription> _subscriptions;
  ExploreBloc _exploreBloc;

  PageController _controller = PageController();
  ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _exploreBloc = widget.exploreBloc;
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      widget.exploreBloc.addConnectionMessage$
        .listen((message) => showMessage(message)),
    ];
  }
  
  void showMessage(ExploreMessage message) {
    print(message);
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _exploreBloc.dispose();
    print('[DEBUG] _ExploreTabsPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        flexibleSpace: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: RaisedButton(
                onPressed: () => {
                  // TODO: search
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
                      color: Colors.black.withOpacity(0.4),
                    ),
                    SizedBox(width: 10),
                    Text(
                      S.of(context).explore_search_hint,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
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
                      label: S.of(context).explore_find_connections,
                      onTap: () => _changePage(0),
                    ),
                    _tabItem(
                      index: 1,
                      label: S.of(context).explore_posts,
                      onTap: () => _changePage(1),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (page) => _currentPage.value = page,
        children: <Widget>[
          ExploreConnectionsTab(
            bloc: _exploreBloc,
          ),
          ExplorePostsTab(
            bloc: _exploreBloc,
          ),
        ],
      ),
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