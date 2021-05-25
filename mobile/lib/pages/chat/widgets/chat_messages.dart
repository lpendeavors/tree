import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/util/asset_utils.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../../../widgets/image_holder.dart';
import '../chat_tabs_state.dart';
import '../chat_tabs_bloc.dart';

class ChatMessages extends StatefulWidget {
  final ChatTabsBloc bloc;
  final String uid;
  final Function(String) mute;

  const ChatMessages({
    Key key,
    @required this.bloc,
    @required this.uid,
    @required this.mute,
  }) : super(key: key);

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  ChatTabsBloc _chatBloc;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _chatBloc = widget.bloc;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<ChatTabsState>(
        stream: _chatBloc.chatTabsState$,
        initialData: _chatBloc.chatTabsState$.value,
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

          if (data.messages.isEmpty) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 150,
              child: EmptyListView(
                title: '',
                description: '',
                icon: Icons.message,
              ),
            );
          }

          return ListView.builder(
            itemCount: data.messages.length,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _chatMessageItem(
                message: data.messages[index],
                group: _getAssociatedGroup(
                  data.messages[index],
                  data.chatRooms,
                  data.groups,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chatMessageItem({
    MessageItem message,
    GroupItem group,
  }) {
    if (group != null) {
      return InkWell(
        onLongPress: () {
          _showRoomOptions(message.roomId);
        },
        onTap: () {
          Navigator.of(context).pushNamed(
            '/chat_room',
            arguments: {
              'roomId': message.roomId,
              'isRoom': message.isRoom,
              'isGroup': message.isGroup,
            },
          );
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
                  if (group != null &&
                      group.members.length > 2 &&
                      message.isConversation &&
                      !message.isGroup)
                    Container(
                      height: 40,
                      width: 40,
                      child: Stack(
                        children: List.generate(
                            group.members.length > 3 ? 3 : group.members.length,
                            (index) {
                          return Padding(
                            padding: EdgeInsets.only(left: 5 + (index * 5.0)),
                            child: ImageHolder(
                              image: group.members[index].image,
                              size: 40,
                            ),
                          );
                        }),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(3),
                      child: ImageHolder(
                        size: 40,
                        image: group.image ?? '',
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Column(
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
                                      group != null ? group.name : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (message.members.length > 2 ||
                                      (message.isRoom || message.isGroup)) ...[
                                    Container(
                                      margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                      padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                                      decoration: BoxDecoration(
                                        color: Color(0xff5c4eb2),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          width: 1,
                                          color: Color(0xfffff3f3f3),
                                        ),
                                      ),
                                      child: Text(
                                        _getLabelText(message),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(width: 5),
                            if (!message.isRead && !message.isMine) ...[
                              Icon(
                                Icons.new_releases,
                                size: 14,
                                color: Color(0xff0072e5),
                              ),
                            ],
                            SizedBox(width: 5),
                            Text(
                              timeago.format(message.sentDate),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xff0f534949),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1,
                              color: Color(0xfffff3f3f3),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // Container(
                                //   width: 10,
                                //   height: 10,
                                //   margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                //   decoration: BoxDecoration(
                                //     color: Color(0xffb27300),
                                //     shape: BoxShape.circle,
                                //     border: Border.all(
                                //       width: 1,
                                //       color: Colors.white,
                                //     ),
                                //   ),
                                // ),
                                Icon(
                                  Icons.message,
                                  size: 10,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    message.message ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.4),
                                    ),
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
              ),
              SizedBox(height: 10),
              Container(
                height: 0.5,
                width: double.infinity,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<List<MemberItem>>(
      future: _getMemberDetails(message.members),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          return Container();
        }

        var otherMembers = List<MemberItem>();
        if (snapshot.hasData) {
          otherMembers =
              snapshot.data.where((m) => m.id != widget.uid).toList();
        }

        return InkWell(
          onLongPress: () {
            _showRoomOptions(message.roomId);
          },
          onTap: () {
            Navigator.of(context).pushNamed(
              '/chat_room',
              arguments: {
                'roomId': message.roomId,
                'isRoom': message.isRoom,
                'isGroup': message.isGroup,
              },
            );
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
                    if (group != null &&
                        group.members.length > 2 &&
                        message.isConversation &&
                        !message.isGroup)
                      Container(
                        height: 40,
                        width: 40,
                        child: Stack(
                          children: List.generate(
                              group.members.length > 3
                                  ? 3
                                  : group.members.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(left: 5 + (index * 5.0)),
                              child: ImageHolder(
                                image: group.members[index].image,
                                size: 40,
                              ),
                            );
                          }),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(3),
                        child: ImageHolder(
                          size: 40,
                          image: group == null
                              ? otherMembers.length > 0
                                  ? otherMembers[0].image ?? ''
                                  : ''
                              : group.image ?? '',
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Column(
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
                                        group != null
                                            ? group.name
                                            : otherMembers.length > 0
                                                ? otherMembers.length > 1
                                                    ? '${otherMembers[0].name} and ${otherMembers.length} others'
                                                    : otherMembers[0].name
                                                : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (message.members.length > 2 ||
                                        (message.isRoom ||
                                            message.isGroup)) ...[
                                      Container(
                                        margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                        padding:
                                            EdgeInsets.fromLTRB(6, 2, 6, 2),
                                        decoration: BoxDecoration(
                                          color: Color(0xff5c4eb2),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                            width: 1,
                                            color: Color(0xfffff3f3f3),
                                          ),
                                        ),
                                        child: Text(
                                          _getLabelText(message),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              if (!message.isRead && !message.isMine) ...[
                                Icon(
                                  Icons.new_releases,
                                  size: 14,
                                  color: Color(0xff0072e5),
                                ),
                              ],
                              SizedBox(width: 5),
                              Text(
                                timeago.format(message.sentDate),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xff0f534949),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                width: 1,
                                color: Color(0xfffff3f3f3),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // Container(
                                  //   width: 10,
                                  //   height: 10,
                                  //   margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  //   decoration: BoxDecoration(
                                  //     color: Color(0xffb27300),
                                  //     shape: BoxShape.circle,
                                  //     border: Border.all(
                                  //       width: 1,
                                  //       color: Colors.white,
                                  //     ),
                                  //   ),
                                  // ),
                                  Icon(
                                    Icons.message,
                                    size: 10,
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      message.message ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(0.4),
                                      ),
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
                ),
                SizedBox(height: 10),
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
          ),
        );
      },
    );
    // return Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: Container(
    //     height: 50,
    //     width: double.infinity,
    //     color: Colors.red,
    //   ),
    // );
  }

  Future<List<MemberItem>> _getMemberDetails(List<String> members) async {
    List<MemberItem> memberDetails = [];

    for (var m in members) {
      var user = await _firestore.doc('userBase/$m').snapshots().first;
      var userEntity = UserEntity.fromDocumentSnapshot(user);

      memberDetails.add(MemberItem(
        id: userEntity.id,
        name: (userEntity.isChurch ?? false)
            ? userEntity.churchName
            : userEntity.fullName,
        image: userEntity.image ?? '',
      ));
    }

    return memberDetails;
  }

  String _getLabelText(MessageItem message) {
    if (message.isGroup) {
      return 'Group';
    } else if (message.isRoom) {
      return 'Chat Room';
    } else {
      return 'Conversation';
    }
  }

  GroupItem _getAssociatedGroup(
    MessageItem message,
    List<GroupItem> rooms,
    List<GroupItem> groups,
  ) {
    var allGroups = List<GroupItem>();
    allGroups.addAll(groups);
    allGroups.addAll(rooms);

    try {
      return allGroups.where((g) => g.id == message.roomId).single;
    } catch (e) {
      return null;
    }
  }

  Future<void> _showRoomOptions(
    String roomId,
  ) async {
    switch (await showDialog<ChatRoomOption>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 180,
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
                          maxHeight: 130,
                        ),
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              SizedBox(height: 5),
                              SimpleDialogOption(
                                child: Text('Mute Chat'),
                                onPressed: () =>
                                    Navigator.pop(context, ChatRoomOption.mute),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
                              ),
                              SimpleDialogOption(
                                child: Text('Delete Chat'),
                                onPressed: () => Navigator.pop(
                                    context, ChatRoomOption.delete),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
                              ),
                              SimpleDialogOption(
                                child: Text('Report'),
                                onPressed: () => Navigator.pop(
                                    context, ChatRoomOption.report),
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
      case ChatRoomOption.mute:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Mute?',
                ),
                content: new Text(
                  "Are you sure you want to mute notificaton from this thread?",
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
            widget.mute(roomId);
          }
        });
        break;
      case ChatRoomOption.delete:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Delete?',
                ),
                content: new Text(
                  "Are you sure you want to delete this thread?",
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
            _chatBloc.unsubscribe(roomId);
          }
        });
        break;
      case ChatRoomOption.report:
        _chatBloc.unsubscribe(roomId);
        Navigator.of(context).pushNamed(
          '/report_group',
          arguments: roomId,
        );
        break;
    }
  }
}
