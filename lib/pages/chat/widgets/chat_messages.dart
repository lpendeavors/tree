import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
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
              return Container();
            },
          );
        },
      ),
    );
  }

  Widget _chatMessageItem({
    GroupItem message,
  }) {
    return InkWell(
      onLongPress: () {
        // TODO: show options menu
      },
      onTap: () {
        // TODO: go to chat room
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
                  child: Container(), // TODO: image holder
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
                            child: Text(
                              message.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}