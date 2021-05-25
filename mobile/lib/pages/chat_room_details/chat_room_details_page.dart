import 'dart:ui';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import '../feed/widgets/feed_list_item.dart';
import '../feed/feed_state.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import '../../widgets/image_holder.dart';
import './chat_room_details_bloc.dart';
import './chat_room_details_state.dart';
import 'widgets/chat_members.dart';

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

class _ChatRoomDetailsPageState extends State<ChatRoomDetailsPage>
    with TickerProviderStateMixin {
  ChatRoomDetailsBloc _roomDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _roomDetailsBloc = widget.initRoomDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    print('[DEBUG] _ChatRoomDetailsState#dispose');
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
                      if (data.chatRoomDetails.isGroup &&
                          !data.chatRoomDetails.isConversation &&
                          data.chatRoomDetails.image != null) ...[
                        Align(
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            height: 250,
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            imageUrl: data.chatRoomDetails.image,
                            placeholder: (context, string) {
                              return Container(
                                height: 250,
                                color: Theme.of(context).primaryColor,
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (data.chatRoomDetails.isGroup &&
                          data.chatRoomDetails.isConversation &&
                          data.chatRoomDetails.image != null) ...[
                        Align(
                          alignment: Alignment.center,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 20,
                            ),
                            child: CachedNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              imageUrl: data.chatRoomDetails.members[0].image,
                            ),
                          ),
                        ),
                      ],
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
                                if (data.chatRoomDetails.members.length <= 2)
                                  ImageHolder(
                                    size: 80,
                                    image:
                                        data.chatRoomDetails.members[0].image,
                                  ),
                                ...List.generate(
                                    data.chatRoomDetails.members.length,
                                    (index) {
                                  var member =
                                      data.chatRoomDetails.members[index];
                                  var padding = index != 1
                                      ? (5 + index * 5).roundToDouble()
                                      : 0;

                                  if (index == 0) return Container();

                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: padding.toDouble(),
                                      ),
                                      child: ImageHolder(
                                        size: 35,
                                        image: member.image ?? "",
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                                          Navigator.of(context).pushNamed(
                                            '/create_message',
                                            arguments: <String, dynamic>{
                                              "type": 1,
                                              "groupId":
                                                  data.chatRoomDetails.id,
                                              "existingMembers": data
                                                  .chatRoomDetails.members
                                                  .map((m) => MemberItem(
                                                        id: m.id,
                                                        name: m.name,
                                                        image: m.image,
                                                        groupAdmin: m.isAdmin,
                                                        token: "",
                                                      ))
                                                  .toList(),
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                    IconButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => _showGroupOptions(
                                        data.chatRoomDetails.id,
                                        data.chatRoomDetails.members,
                                        data.chatRoomDetails.isAdmin,
                                      ),
                                    ),
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
                      //],
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
                          Text('About'),
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
                              Navigator.of(context).pushNamed(
                                '/profile',
                                arguments:
                                    data.chatRoomDetails.members[index].id,
                              );
                            },
                            child: AbsorbPointer(
                              absorbing: true,
                              child: ImageHolder(
                                size: 40,
                                image:
                                    data.chatRoomDetails.members[index].image,
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
                        'isRoom': true,
                        'isGroup': true,
                      },
                    );
                  }),
              if (!data.chatRoomDetails.isAdmin &&
                  !data.chatRoomDetails.wallEnabled) ...[
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
              if (data.chatRoomDetails.wallEnabled ||
                  data.chatRoomDetails.isAdmin) ...[
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
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/edit_post',
                                arguments: <String, dynamic>{
                                  'groupId': data.chatRoomDetails.id,
                                  'postId': null,
                                },
                              );
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/edit_poll',
                              arguments: <String, dynamic>{
                                'groupId': data.chatRoomDetails.id,
                                'pollId': null,
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Poll',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
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
                    return FeedListItem(
                      context: context,
                      tickerProvider: this,
                      feedItem: data.chatRoomPosts[index],
                      likeFeedItem: (item) {
                        // TODO: finish saving like
                        // _feedBloc.postToLikeChanged(item);
                        // _feedBloc.likePostChanged(!data.feedItems[index].isLiked);
                        // _feedBloc.saveLikeValue();
                      },
                      admin: (widget.userBloc.loginState$.value as LoggedInUser)
                          .isAdmin,
                      answerPoll: (int) {},
                      deletePost: () {},
                      isFeed: true,
                      reportPost: () {},
                      share: (bool) {},
                      unconnect: () {},
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showGroupOptions(
    String groupId,
    List<ChatRoomMemberItem> members,
    bool admin,
  ) async {
    switch (await showDialog<ChatOption>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: admin ? 250 : 180,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(
                            width: 15,
                          ),
                          Image.asset(
                            ic_launcher,
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(
                              'Tree',
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
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    Container(
                      color: Colors.white,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: admin ? 200 : 110,
                        ),
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              SizedBox(height: 5),
                              if (admin) ...[
                                SimpleDialogOption(
                                  child: Text('Update Group'),
                                  onPressed: () =>
                                      Navigator.pop(context, ChatOption.update),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SimpleDialogOption(
                                  child: Text('Delete Group'),
                                  onPressed: () =>
                                      Navigator.pop(context, ChatOption.delete),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SimpleDialogOption(
                                  child: Text('Suspend Group'),
                                  onPressed: () => Navigator.pop(
                                      context, ChatOption.suspend),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
                              SimpleDialogOption(
                                child: Text('View Members'),
                                onPressed: () => Navigator.pop(
                                    context, ChatOption.viewMembers),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
                              ),
                              SimpleDialogOption(
                                child: Text('Mute Notifications'),
                                onPressed: () =>
                                    Navigator.pop(context, ChatOption.mute),
                              ),
                              SizedBox(height: 5),
                              if (!admin) ...[
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SimpleDialogOption(
                                  child: Text('Leave Group'),
                                  onPressed: () =>
                                      Navigator.pop(context, ChatOption.leave),
                                ),
                                SizedBox(height: 5),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        })) {
      case ChatOption.update:
        Navigator.of(context).pushNamed(
          '/create_group',
          arguments: <String, dynamic>{
            'groupId': groupId,
            'members': members.map((m) {
              return MemberItem(
                id: m.id,
                name: m.name,
                token: "",
                image: m.image,
                groupAdmin: m.isAdmin,
              );
            }).toList(),
          },
        );
        break;
      case ChatOption.delete:
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Delete?',
                ),
                content: new Text(
                  "Are you sure you want to delete this group?",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES', style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            }).then((value) {
          if (value) {
            _roomDetailsBloc.deleteGroup();
          }
        });

        Navigator.of(context).pop();
        break;
      case ChatOption.mute:
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Mute?',
                ),
                content: new Text(
                  "Are you sure you want to mute notificaton from this group?",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES', style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            }).then((value) {
          if (value) {
            _roomDetailsBloc.muteGroup();
          }
        });
        break;
      case ChatOption.suspend:
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Suspend?',
                ),
                content: new Text(
                  "Are you sure you want to suspend this group?",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES', style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            }).then((value) {
          if (value) {
            _roomDetailsBloc.suspendGroup();
          }
        });

        Navigator.of(context).pop();
        break;
      case ChatOption.viewMembers:
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return ChatMembersPage(
                isAdmin: admin,
                members: members,
                onMakeAdmin: (userId) {
                  _roomDetailsBloc.makeAdmin(userId);
                },
                onRemove: (userId) {
                  _roomDetailsBloc.leaveGroup(userId);
                },
              );
            }),
          );
        });
        break;
      case ChatOption.leave:
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Leave?',
                ),
                content: new Text(
                  "Are you sure you want to leave this group?",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES', style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            }).then((value) {
          if (value) {
            var user = (widget.userBloc.loginState$.value as LoggedInUser);
            _roomDetailsBloc.leaveGroup(user.uid);
          }
        });
        break;
    }
  }
}
