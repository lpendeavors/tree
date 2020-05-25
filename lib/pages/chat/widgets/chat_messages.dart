import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../../../widgets/image_holder.dart';
import '../chat_tabs_state.dart';
import '../chat_tabs_bloc.dart';

class ChatMessages extends StatefulWidget {
  final ChatTabsBloc bloc;
  
  const ChatMessages({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
} 


class _ChatMessagesState extends State<ChatMessages> {
  ChatTabsBloc _chatBloc;
  
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _chatMessageItem({
    MessageItem message,
  }) {
    return InkWell(
      onLongPress: () {
        // TODO: show options menu
      },
      onTap: () {
        Map<String, dynamic> chatRoomArgs = {
          'roomId': message.roomId,
          'isGroup': message.isGroup,
        };

        Navigator.of(context).pushNamed(
          '/chat_room',
          arguments: chatRoomArgs,
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
                // TODO: stack member images
                Container(
                  padding: EdgeInsets.all(3),
                  child: ImageHolder(
                    size: 40,
                    image: message.image,
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
                                    message.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
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
                            ),
                          ),
                          SizedBox(width: 5),
                          // Icon(
                          //   Icons.new_releases,
                          //   size: 14,
                          //   color: Color(0xff0072e5),
                          // ),
                          // SizedBox(width: 5),
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
                                  message.message,
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

  String _getLabelText(
    MessageItem message
  ) {
    if (message.isRoom) {
      return 'Chat Room';
    } else if (message.isGroup && !message.isConversation) {
      return 'Group';
    } else {
      return 'Conversation';
    }
  }
}