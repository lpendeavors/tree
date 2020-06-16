import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../../../widgets/image_holder.dart';
import '../chat_tabs_state.dart';
import '../chat_tabs_bloc.dart';

class ChatGroups extends StatefulWidget {
  final ChatTabsBloc bloc;

  const ChatGroups({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  _ChatGroupsState createState() => _ChatGroupsState();
}

class _ChatGroupsState extends State<ChatGroups> {
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

          if (data.groups.isEmpty) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 150,
              child: EmptyListView(
                title: 'No Groups',
                description: '~You are not in any groups~',
                icon: Icons.group,
              ),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,     
              childAspectRatio: 0.8,
            ),
            padding: EdgeInsets.all(8),
            itemCount: data.groups.length,
            itemBuilder: (context, index) {
              var group = data.groups[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/chat_room_details',
                      arguments: group.id,
                    );
                  },
                  onLongPress: () {
                    // TODO: show group options dialog
                  },
                  radius: 10,
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Image(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          image: CacheImage(group.image),
                        ),
                      ),
                      Container(
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
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              group.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              height: 0.4,
                              width: double.infinity,
                              color: Colors.white,
                              margin: EdgeInsets.only(top: 5, bottom: 5),
                            ),
                            Text(
                              '${group.members.length} members',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          child: Icon(
                            Icons.lock_open,
                            size: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (group.isConversation) ...[
                        Align(
                          child: Container(
                            height: 55,
                            width: 55,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                ImageHolder(
                                  size: 50,
                                  image: group.image,
                                ),
                                ...List.generate(
                                  group.members.length,
                                  (index) {
                                    return Align(
                                      alignment: Alignment.bottomCenter,
                                      child: ImageHolder(
                                        size: 25,
                                        image: group.members[index].image,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}