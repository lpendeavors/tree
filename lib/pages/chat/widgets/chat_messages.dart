import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../../../widgets/image_holder.dart';
import '../chat_tabs_state.dart';
import '../chat_tabs_bloc.dart';

class ChatMessages extends StatefulWidget {
  final ChatTabsBloc bloc;
  final String uid;

  const ChatMessages({
    Key key,
    @required this.bloc,
    @required this.uid,
  }) : super(key: key);

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  ChatTabsBloc _chatBloc;
  Firestore _firestore = Firestore.instance;

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
            // TODO: show options menu
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
                        message.isConversation)
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
                                    if (message.isConversation &&
                                        message.members.length > 2) ...[
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
  }

  Future<List<MemberItem>> _getMemberDetails(List<String> members) async {
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

    return memberDetails;
  }

  String _getLabelText(MessageItem message) {
    if (message.isRoom) {
      return 'Chat Room';
    } else if (message.isGroup && !message.isConversation) {
      return 'Group';
    } else {
      return 'Conversation';
    }
  }

  GroupItem _getAssociatedGroup(
    MessageItem message,
    List<GroupItem> groups,
  ) {
    try {
      return groups.where((g) => g.id == message.roomId).single;
    } catch (e) {
      return null;
    }
  }
}
