import 'package:cached_network_image/cached_network_image.dart';
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
              var nonDefaultRooms =
                  data.chatRooms.where((r) => !r.isDefault).toList();

              return _chatRoomItem(
                room: data.chatRooms[index],
                color: data.chatRooms[index].isDefault
                    ? chatRoomColors[index - nonDefaultRooms.length]
                    : null,
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
        onTap: () {
          Navigator.of(context).pushNamed(
            '/chat_room_details',
            arguments: room.id,
          );
        },
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
                          ? CachedNetworkImage(
                              imageUrl: room.image,
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                    Container(
                      color: color != null
                          ? Color(color).withOpacity(0.7)
                          : Colors.transparent,
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
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              room.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'active now',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${room.members.length} members',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        child: Image.asset(
                          appIcon,
                          height: 15,
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
