import 'dart:async';

import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './widgets/chat_messages.dart';
import './widgets/chat_rooms.dart';
import './widgets/chat_groups.dart';
import './chat_tabs_bloc.dart';
import 'package:flutter/material.dart';

class ChatTabsPage extends StatefulWidget {
  final ChatTabsBloc chatBloc;
  final UserBloc userBloc;

  const ChatTabsPage({
    Key key, 
    @required this.userBloc,
    @required this.chatBloc,
  }) : super(key: key);

  @override
  _ChatTabsPageState createState() => _ChatTabsPageState();
}

class _ChatTabsPageState extends State<ChatTabsPage> {
  List<StreamSubscription> _subscriptions;
  ChatTabsBloc _chatBloc;

  PageController _controller = PageController();
  ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _chatBloc = widget.chatBloc;
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _chatBloc.dispose();
    print('_ChatTabsPageState#dispose');

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
            top: true,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: RaisedButton(
                      onPressed: () async {

                      },
                      color: Colors.grey[50],
                      elevation: 0,
                      padding: EdgeInsets.only(top: 12, bottom: 12, right: 10, left:10),
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
                            color: Colors.black54,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Search and discover',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/chat_settings',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
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
                      label: 'MESSAGES',
                      onTap: () => _changePage(0),
                    ),
                    _tabItem(
                      index: 1,
                      label: 'CHAT ROOMS',
                      onTap: () => _changePage(1),
                    ),
                    _tabItem(
                      index: 2,
                      label: 'GROUPS',
                      onTap: () => _changePage(2),
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
          ChatMessages(
            bloc: widget.chatBloc,
          ),
          ChatRooms(
            bloc: widget.chatBloc,
          ),
          Container(color: Colors.blue),
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