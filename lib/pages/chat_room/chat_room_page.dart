import 'dart:async';

import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
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

  @override
  void initState() {
    super.initState();

    _chatRoomBloc = widget.initChatRoomBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    print('[DEBUG] ChatRoomPageState#dispose');
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
                          if (data.details.isGroup && !data.details.isConversation) {
                            Navigator.of(context).pushNamed(
                              '/chat_room_details', 
                              arguments: data.details.id,
                            );
                          } else if (data.details.members.length > 2) {
                            // TODO: view members
                          } else {
                            Navigator.of(context).pushNamed(
                              '/profile',
                              arguments: data.details.members[1].uid,
                            );
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            if (!data.details.isGroup && !data.details.isConversation)
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
                                    Image(
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      image: CacheImage(data.details.image),
                                    ),
                                  ],
                                ),
                              )
                            else if (data.details.members.length > 1 && data.details.isConversation)
                              // TODO: Stacked images
                              Container()
                            else 
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
                                    Image(
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      image: CacheImage(data.details.groupImage),
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
                                  if (!data.details.isGroup || !data.details.isConversation)
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
                                  else if (data.details.members.length > 2 && data.details.isConversation)
                                    Text.rich(
                                      TextSpan(
                                        children: List.generate(
                                          data.details.members
                                            .where((m) => m.uid != (widget.userBloc.loginState$ as LoggedInUser).uid)
                                            .length, 
                                          (index) {
                                            return TextSpan(
                                              text: '${data.details.members[0].fullName} and ${data.details.members.length} more',
                                            );
                                          }
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                  else
                                    Text(
                                      data.details.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  SizedBox(height: 5),
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
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(
                            width: 1,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Mute chat
                        },
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
                                  data.messages[index].sentDate.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          data.messages[index].isMine
                            ? _outgoingMessage(data.messages[index])
                            : _incommingMessage(data.messages[index]),
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
              if (data.details.isGroup) ...[
                Container(
                  width: double.infinity,
                  color: Color(0xff0f534949),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          child: FlatButton(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onPressed: () {

                            },
                            child: Icon(
                              Icons.keyboard,
                              size: 20,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 120,
                            ),
                            child: TextField(
                              onChanged: (text) {
                                // TODO: set message
                                print(text);
                              },
                              cursorWidth: 1,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.multiline,
                              scrollPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Type a message',
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          child: FlatButton(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onPressed: () {
                              // TODO: send message
                            },
                            child: Icon(
                              Icons.send,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        }
      ),
    );
  }

  Widget _outgoingMessage(ChatMessageItem messageItem) {
    Widget messageWidget;

    switch (messageItem.type) {
      case MessageType.text:
        messageWidget = GestureDetector(
          onLongPress: () {
            // TODO: show chat options
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(60, 0, 20, 15),
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: BoxDecoration(
              color: messageItem.isRead 
                ? Color(0xFF6CA748)
                : Color(0xFF9CC83F),
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
                  messageItem.sentDate.toString(),
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
      case MessageType.doc:
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

  Widget _incommingMessage(ChatMessageItem messageItem) {
    Widget messageWidget;

    switch (messageItem.type) {
      case MessageType.text:
        messageWidget = Stack(
          children: <Widget>[
            GestureDetector(
              onLongPress: () {
                // TODO: show options
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
                    Text(
                      messageItem.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
            ImageHolder(
              size: 40,
              image: messageItem.image,
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
      case MessageType.doc:
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
}