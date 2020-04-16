import 'dart:async';
import 'dart:ui';

import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import './chat_state.dart';
import '../chat_room/chat_room_bloc.dart';


class ChatPage extends StatefulWidget {

  ChatPage({
    Key key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final PageController _pageController = PageController();
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        flexibleSpace: PreferredSize(
            child: SafeArea(
              top: true,
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: RaisedButton(
                          onPressed: () {},
                          color: Colors.grey[50],
                          elevation: 0,
                          padding: EdgeInsets.all(12.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.black26, width: 1.0)
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Search and discover",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        flex: 1,
                      ),
                      IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {}
                      )
                    ],
                  )
              ),
            ),
            preferredSize: Size.fromHeight(10.0)
        ),
        bottom: PreferredSize(
          child: Container(
            height: 40.0,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0, top: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).primaryColor
            ),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeOutSine);
                      setState(() {
                        _currentTab = 0;
                      });
                    },
                    child: Container(
                      child: Center(
                          child: Text(
                            "MESSAGES",
                            style: TextStyle(
                                fontSize: 14.0,
                                color: _currentTab == 0 ? Theme.of(context).primaryColor : Colors.white70,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                      decoration: BoxDecoration(
                          color: _currentTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeOutSine);
                      setState(() {
                        _currentTab = 1;
                      });
                    },
                    child: Container(
                      child: Center(
                          child: Text(
                            "CHAT ROOMS",
                            style: TextStyle(
                                fontSize: 14.0,
                                color: _currentTab == 1 ? Theme.of(context).primaryColor : Colors.white70,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                      decoration: BoxDecoration(
                          color: _currentTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeOutSine);
                      setState(() {
                        _currentTab = 2;
                      });
                    },
                    child: Container(
                      child: Center(
                          child: Text(
                            "GROUPS",
                            style: TextStyle(
                                fontSize: 14.0,
                                color: _currentTab == 2 ? Theme.of(context).primaryColor : Colors.white70,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                      decoration: BoxDecoration(
                          color: _currentTab == 2 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
          preferredSize: Size.fromHeight(56),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          ConversationList(),
          ChatRoomList(),
          GroupList(),
        ],
      )
    );
  }
}

class ConversationList extends StatefulWidget {

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  List<StreamSubscription> _subscriptions;
  FeedBloc _feedBloc;

  @override
  void initState() {
    super.initState();

    _feedBloc = widget.feedBloc;
    /*_subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/'))),
    ];*/
  }

  @override
  void dispose() {
    //_subscriptions.forEach((s) => s.cancel());
    //_feedBloc.dispose();
    print('_ConversationListState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<RoomListState>(
        //stream: _feedBloc.feedListState$,
        //initialData: _feedBloc.feedListState$.value,
        builder: (context, snapshot) {
          RoomListState data = snapshot.data;
          return ListView.builder(
              itemCount: data.roomItems.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index){
                return ChatRoomView(
                  roomItem: data.roomItems[index],
                );
              }
          );
        }
      ),
    );
  }
}

class ChatRoomView extends StatelessWidget {
  final RoomItem roomItem;

  const ChatRoomView({
    Key key,
    this.roomItem
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){

      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image(
                        image: CacheImage(this.roomItem.imageUrl),
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                    ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: new Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    this.roomItem.roomTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'NirmalaB', fontSize: 18.0),
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
                                    padding: const EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).indicatorColor,
                                        borderRadius: BorderRadius.circular(25.0)
                                    ),
                                    child: Text(
                                      "Chat Room",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'NirmalaB', fontSize: 12.0),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            this.roomItem.chatTime,
                            style: TextStyle(color: Colors.black26, fontFamily: 'Nirmala', fontSize: 14.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(25.0)
                        ),
                        child: new Padding(
                          padding: const EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    this.roomItem.previewText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black45, fontFamily: 'Nirmala', fontSize: 12.0)
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            new Divider()
          ],
        ),
      ),
    );
  }
}

class ChatRoomList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.teal,
    );
  }
}

class GroupList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.orange,
    );
  }
}

/*
Notes:
Load real chat rooms


Possibly rework database???
 */