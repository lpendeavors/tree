import 'dart:async';

import 'package:cache_image/cache_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:treeapp/models/old/group_member.dart';
import 'package:treeapp/pages/chat_room/widgets/chat_input.dart';
import 'package:treeapp/util/asset_utils.dart';
import '../../widgets/empty_list_view.dart';
import '../../widgets/image_holder.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
import './chat_room_bloc.dart';
import './chat_room_state.dart';

class ChatRoomPage extends StatefulWidget {
  final UserBloc userBloc;
  final Function() initChatRoomBloc;

  const ChatRoomPage({
    Key key,
    @required this.userBloc,
    @required this.initChatRoomBloc,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  ChatRoomBloc _chatRoomBloc;
  List<StreamSubscription> _subscriptions;
  Firestore _firestore;

  @override
  void initState() {
    super.initState();

    _firestore = Firestore.instance;
    _chatRoomBloc = widget.initChatRoomBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _chatRoomBloc.message$.listen((message) => _showMessageResult(message)),
    ];
  }

  void _showMessageResult(ChatRoomMessage message) {
    print(message);
  }

  @override
  void dispose() {
    print('[DEBUG] _ChatRoomPageState#dispose');
    _subscriptions.forEach(((s) => s.cancel()));
    _chatRoomBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: StreamBuilder<ChatRoomState>(
          stream: _chatRoomBloc.chatRoomState$,
          initialData: _chatRoomBloc.chatRoomState$.value,
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

            var user = widget.userBloc.loginState$.value as LoggedInUser;

            if (data.messages.isNotEmpty) {
              var unread = data.messages
                  .where((m) => !m.isRead && m.members.contains(user.uid))
                  .toList();
              if (unread.isNotEmpty) {
                _chatRoomBloc.markRead(unread.map((u) => u.id).toList());
              }
            }

            if (data.details != null &&
                !data.details.members.contains(user.uid)) {
              _chatRoomBloc.joinMembers();
            }

            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Icon(
                              Icons.keyboard_backspace,
                              size: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          onTap: () {
                            if (data.details != null) {
                              if (data.details.isGroup &&
                                  !data.details.isConversation) {
                                Navigator.of(context).pushNamed(
                                  '/chat_room_details',
                                  arguments: data.details.id,
                                );
                              } else if (data.details.members.length > 2) {
                                // TODO: view members
                              }
                            } else {
                              var uid = (widget.userBloc.loginState$.value
                                      as LoggedInUser)
                                  .uid;
                              var otherMember = data.messages.last.members
                                  .where((m) => m != uid)
                                  .toList()[0];
                              Navigator.of(context).pushNamed(
                                '/profile',
                                arguments: otherMember,
                              );
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              Card(
                                shape: CircleBorder(),
                                margin: EdgeInsets.all(0),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.transparent,
                                elevation: 0.5,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      color: Color(0xffe46514),
                                      child: Center(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                    // if (otherMembers.length == 1 &&
                                    //     otherMembers[0].image.isNotEmpty)
                                    //   CachedNetworkImage(
                                    //     width: 40,
                                    //     height: 40,
                                    //     fit: BoxFit.cover,
                                    //     imageUrl: otherMembers[0].image,
                                    //   ),
                                    if (data.details != null &&
                                        data.details.groupImage != null)
                                      CachedNetworkImage(
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        imageUrl: data.details.groupImage,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (data.details != null)
                                      Text(
                                        data.details.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    else
                                      FutureBuilder(
                                          future: _getOtherMembers(
                                              data.messages.last.members),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.none &&
                                                snapshot.hasData == null) {
                                              return Container();
                                            }

                                            var uid = (widget
                                                    .userBloc
                                                    .loginState$
                                                    .value as LoggedInUser)
                                                .uid;
                                            var otherMembers =
                                                List<MemberItem>();
                                            if (snapshot.hasData) {
                                              otherMembers = snapshot.data
                                                  .where((m) => m.id != uid)
                                                  .toList();
                                            }

                                            return Text(
                                              otherMembers.length > 0
                                                  ? otherMembers.length == 1
                                                      ? otherMembers[0].name
                                                      : '${otherMembers[0].name} and ${otherMembers.length - 1} others'
                                                  : '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            );
                                          }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        height: 30,
                        width: 30,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          color: Color(0xFF6CA748),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              width: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                          onPressed: () {},
                          child: Center(
                            child: Icon(
                              Icons.notifications_off,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.1),
                  margin: EdgeInsets.only(top: 5),
                ),
                Expanded(
                  flex: 1,
                  child: Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: data.messages.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: data.messages[index].isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            if (data.messages[index].showDate) ...[
                              Center(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                  child: Text(
                                    '${DateFormat.MMM().add_d().add_jm().format(data.messages[index].sentDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            data.messages[index].isMine
                                ? _outgoingMessage(
                                    data.messages[index], data.details.isAdmin)
                                : _incommingMessage(
                                    data.messages[index], data.details.isAdmin),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.1),
                  margin: EdgeInsets.only(top: 5),
                ),
                ChatInput(
                  chatRoomBloc: _chatRoomBloc,
                  userImage:
                      (widget.userBloc.loginState$.value as LoggedInUser).image,
                ),
              ],
            );
          }),
    );
  }

  Future<List<MemberItem>> _getOtherMembers(
    List<String> members,
  ) async {
    var memberDetails = List<MemberItem>();

    var snapshots = await _firestore
        .collection('userBase')
        .where('uid', whereIn: members)
        .getDocuments();

    for (var doc in snapshots.documents) {
      memberDetails.add(
        MemberItem(
          id: doc.documentID,
          name: doc['fullName'],
          image: doc['image'],
        ),
      );
    }

    print(memberDetails);

    return memberDetails;
  }

  Widget _outgoingMessage(ChatMessageItem messageItem, bool isAdmin) {
    Widget messageWidget;

    switch (messageItem.type) {
      case MessageType.text:
        messageWidget = GestureDetector(
          onLongPress: () {
            if (isAdmin) {
              _showMessageOptions(messageItem);
            }
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(60, 0, 20, 15),
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: BoxDecoration(
              color: messageItem.isRead ? Color(0xFF6CA748) : Color(0xFF9CC83F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  messageItem.message,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  timeago.format(messageItem.sentDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case MessageType.image:
        messageWidget = Container();
        break;
      case MessageType.video:
        messageWidget = Container();
        break;
      case MessageType.gif:
        messageWidget = Container();
        break;
      default:
        messageWidget = Container();
    }

    return messageWidget;
  }

  Widget _incommingMessage(ChatMessageItem messageItem, bool isAdmin) {
    Widget messageWidget;

    switch (messageItem.type) {
      case MessageType.text:
        messageWidget = Stack(
          children: <Widget>[
            GestureDetector(
              onLongPress: () {
                if (isAdmin) {
                  _showMessageOptions(messageItem);
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(40, 0, 60, 15),
                padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
                decoration: BoxDecoration(
                  color: Color(0xfffff3f3f3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/profile',
                          arguments: messageItem.userId,
                        );
                      },
                      child: Text(
                        messageItem.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      messageItem.message,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      timeago.format(messageItem.sentDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                print(messageItem.image);
              },
              child: ImageHolder(
                size: 40,
                image: messageItem.image,
              ),
            ),
          ],
        );
        break;
      case MessageType.image:
        messageWidget = Container();
        break;
      case MessageType.video:
        messageWidget = Container();
        break;
      case MessageType.gif:
        messageWidget = Container();
        break;
      default:
        messageWidget = Container();
    }

    return messageWidget;
  }

  Future<void> _showMessageOptions(ChatMessageItem message) async {
    switch (await showDialog<MessageOption>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 140,
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
                          maxHeight: 90,
                        ),
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              SizedBox(height: 5),
                              SimpleDialogOption(
                                child: Text('Copy'),
                                onPressed: () =>
                                    Navigator.pop(context, MessageOption.copy),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
                              ),
                              SizedBox(height: 5),
                              SimpleDialogOption(
                                child: Text('Delete'),
                                onPressed: () => Navigator.pop(
                                    context, MessageOption.delete),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
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
          );
        })) {
      case MessageOption.delete:
        _chatRoomBloc.deleteMessage(message.id);
        break;
      case MessageOption.copy:
        print('copy');
        break;
    }
  }
}
