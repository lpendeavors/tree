import 'dart:async';
import 'dart:ui';

import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';

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
          ChatRoomList(),
          ChatRoomList2()
        ],
      )
    );
  }
}

class ChatRoomList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index){
          return ChatRoomItem();
        }
    );
  }
}
class ChatRoomItem extends StatelessWidget {
  final String imageUrl;
  final String roomTitle;
  final String previewText;
  final String chatTime;

  const ChatRoomItem({
    Key key,
    this.imageUrl = "https://firebasestorage.googleapis.com/v0/b/tree-app-dabd0.appspot.com/o/0005a0a0-f5b0-11e9-b218-a78e6009bf12?alt=media&token=67fff13a-b95c-49d3-bfc1-1fc85bcd34d9",
    this.roomTitle = "Test Room",
    this.previewText = "This room is fake!!!",
    this.chatTime = "11:47 PM"
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
                        image: CacheImage(imageUrl),
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
                                    roomTitle,
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
                            chatTime,
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
                                    previewText,
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

class ChatRoomList2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index){
          return ChatRoomItem2();
        }
    );
  }
}
class ChatRoomItem2 extends StatelessWidget {
  final String imageUrl;
  final String roomTitle;
  final String previewText;
  final String chatTime;

  const ChatRoomItem2({
    Key key,
    this.imageUrl = "https://firebasestorage.googleapis.com/v0/b/tree-app-dabd0.appspot.com/o/0005a0a0-f5b0-11e9-b218-a78e6009bf12?alt=media&token=67fff13a-b95c-49d3-bfc1-1fc85bcd34d9",
    this.roomTitle = "Test Room",
    this.previewText = "This room is fake!!!",
    this.chatTime = "11:47 PM"
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
                        image: CacheImage(imageUrl),
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
                                    roomTitle,
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
                            chatTime,
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
                                      previewText,
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

/*
Notes:
Correct Names
Make all three tabs work properly
Stop loading fake data
Work from the ground up state? -> bloc -> repository
Possibly rework database???
 */