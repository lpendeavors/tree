import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import 'package:smart_text_view/smart_text_view.dart';
import '../feed/widgets/feed_list_item.dart';
import '../feed/feed_state.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import '../../widgets/image_holder.dart';
import './chat_room_details_bloc.dart';
import './chat_room_details_state.dart';

class ChatRoomDetailsPage extends StatefulWidget {
  final UserBloc userBloc;
  final Function() initRoomDetailsBloc;

  const ChatRoomDetailsPage({
    Key key,
    @required this.userBloc,
    @required this.initRoomDetailsBloc,
  }) : super(key: key);

  @override
  _ChatRoomDetailsPageState createState() => _ChatRoomDetailsPageState();
}

class _ChatRoomDetailsPageState extends State<ChatRoomDetailsPage> {
  ChatRoomDetailsBloc _roomDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _roomDetailsBloc = widget.initRoomDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    print('[DEBUG] ChatRoomDetailsState#dispose');
    _subscriptions.forEach((s) => s.cancel());
    _roomDetailsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ChatRoomDetailsState>(
        stream: _roomDetailsBloc.chatRoomDetailsState$,
        initialData: _roomDetailsBloc.chatRoomDetailsState$.value,
        builder: (context, snapshot) {
          var data = snapshot.data;

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

          return ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // TODO: show image
                },
                child: Container(
                  height: 250,
                  child: Stack(
                    children: <Widget>[
                      if (data.chatRoomDetails.isGroup && !data.chatRoomDetails.isConversation) ...[
                        Align(
                          alignment: Alignment.center,
                          child: Image(
                            fit: BoxFit.cover,
                            height: 250,
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            image: CacheImage(data.chatRoomDetails.image),
                          ),
                        ),
                      ],
                      if (data.chatRoomDetails.isGroup && data.chatRoomDetails.isConversation) ...[
                        Align(
                          alignment: Alignment.center,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 20,
                            ),
                            child: Image(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              image: CacheImage(data.chatRoomDetails.members[0].image),
                            ),
                          ),
                        ),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.9),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        if (data.chatRoomDetails.isConversation) ...[
                          Align(
                            child: Container(
                              height: 85,
                              width: 85,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  ImageHolder(
                                    size: 80,
                                    image: data.chatRoomDetails.members[0].image,
                                  ),
                                  ...List.generate(
                                    data.chatRoomDetails.members.length,
                                    (index) {
                                      var member = data.chatRoomDetails.members[index];
                                      var padding = index != 1 
                                        ? (5 + index * 5).roundToDouble()
                                        : 0;

                                      if (index == 0) 
                                        return Container();

                                      return Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: padding,
                                          ),
                                          child: ImageHolder(
                                            size: 35,
                                            image: member.image,
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 25,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    BackButton(
                                      color: Colors.white,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        if (data.chatRoomDetails.isAdmin) ...[
                                          IconButton(
                                            icon: Icon(
                                              Icons.person_add,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              // TODO: add members
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              /// TODO: show options
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  data.chatRoomDetails.name,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 0.2,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'About'
                          ),
                          SizedBox(height: 8),
                          Text(
                            data.chatRoomDetails.description,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${data.chatRoomDetails.members.length} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: ListView.builder(
                        itemCount: data.chatRoomDetails.members.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          return GestureDetector(
                            onTap: () {
                              // TODO: go to profile
                            },
                            child: AbsorbPointer(
                              absorbing: true,
                              child: ImageHolder(
                                size: 40,
                                image: data.chatRoomDetails.members[index].image,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              RaisedButton(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ENTER ROOM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.navigate_next,
                      size: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/chat_room',
                    arguments: <String, dynamic>{
                      'roomId': data.chatRoomDetails.id,
                      'isGroup': false,
                    },
                  );
                }
              ),
              if (!data.chatRoomDetails.isAdmin && !data.chatRoomDetails.wallEnabled) ...[
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(
                    bottom: 0,
                    top: 10,
                    right: 10,
                    left: 10,
                  ),
                  child: Container(
                    color: Colors.red,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.info,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              'Sorry posting on group wall has been disabled. \n Only Admins can share post on the group wall.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (data.chatRoomDetails.wallEnabled || data.chatRoomDetails.isAdmin) ...[
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(
                    bottom: 10,
                    top: 10,
                  ),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 50,
                          child: FlatButton(
                            color: Colors.white,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            onPressed: () {
                              // TODO: new post
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Share to wall',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      child: Icon(
                                        Icons.videocam,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 0.5,
                        color: Colors.black.withOpacity(0.1),
                      ),
                      Container(
                        height: 50,
                        child: FlatButton(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          onPressed: () {
                            // TODO: create poll
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  'Poll',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.help,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Container(
                height: 0.4,
                width: double.infinity,
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              ),
              if (data.chatRoomPosts.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Posts',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.chatRoomPosts.length,
                  padding: EdgeInsets.only(top: 10),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container();
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}