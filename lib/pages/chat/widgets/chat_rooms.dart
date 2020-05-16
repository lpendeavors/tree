import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../../../util/asset_utils.dart';
import '../chat_tabs_state.dart';
import '../chat_tabs_bloc.dart';

class ChatRooms extends StatefulWidget {
  final ChatTabsBloc bloc;

  const ChatRooms({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  _ChatRoomsState createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
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

          if (data.chatRooms.isEmpty) {
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
            itemCount: data.chatRooms.length,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _chatRoomItem(
                room: data.chatRooms[index],
                color: chatRoomColors[index],
              );
            },
          );
        },
      ),
    );
  }

  Widget _chatRoomItem({
    GroupItem room,
    int color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onLongPress: () => print('lp'),
        onTap: () => print('tap'),
        radius: 10,
        borderRadius: BorderRadius.circular(15),
        child: Card(
          child: Container(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: room.image != null
                        ? Image( 
                          image: CacheImage(room.image),
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                        )
                        : Container(),
                    ),
                    Container(
                      color: Color(color),
                      height: 150,
                    ),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}