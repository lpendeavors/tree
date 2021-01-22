import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/pages/chat_room_details/chat_room_details_state.dart';
import 'package:treeapp/util/asset_utils.dart';

enum MemberOption { makeAdmin, remove }

class ChatMembersPage extends StatelessWidget {
  final List<ChatRoomMemberItem> members;
  final void Function(String) onMakeAdmin;
  final void Function(String) onRemove;
  final bool isAdmin;

  ChatMembersPage({
    @required this.members,
    @required this.onMakeAdmin,
    @required this.onRemove,
    @required this.isAdmin,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          '${members.length} Members',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: members.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return _userItem(
              members[index],
              context,
            );
          },
        ),
      ),
    );
  }

  Widget _userItem(
    ChatRoomMemberItem user,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/profile',
          arguments: user.id,
        );
      },
      onLongPress: () {
        if (isAdmin) {
          _showMemberOptions(context, user.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: ClipRRect(
                child: AnimatedContainer(
                  curve: Curves.ease,
                  alignment: Alignment.center,
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                      color: Colors.black26, shape: BoxShape.circle),
                  width: 60.0,
                  height: 60.0,
                  child: Stack(
                    children: <Widget>[
                      new Card(
                        margin: EdgeInsets.all(0),
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        elevation: 0.5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: 60.0,
                              height: 60.0,
                              child: Center(
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 14.0)),
                            ),
                            if (user.image != null && user.image.isNotEmpty)
                              CachedNetworkImage(
                                width: 60.0,
                                height: 60.0,
                                fit: BoxFit.cover,
                                imageUrl: user.image,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.0),
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 5.0),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    // Text(
                    //   'Hey im new to tree',
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //     fontSize: 13.0,
                    //     fontFamily: 'Nirmala',
                    //     color: Colors.black54,
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMemberOptions(
    BuildContext context,
    String memberId,
  ) async {
    switch (await showDialog<MemberOption>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 150,
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
                          maxHeight: 80,
                        ),
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              SizedBox(height: 5),
                              SimpleDialogOption(
                                child: Text('Make Admin'),
                                onPressed: () => Navigator.pop(
                                    context, MemberOption.makeAdmin),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
                              ),
                              SimpleDialogOption(
                                child: Text('Remove User'),
                                onPressed: () =>
                                    Navigator.pop(context, MemberOption.remove),
                              ),
                              SizedBox(height: 5),
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
      case MemberOption.remove:
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Remove?',
                ),
                content: new Text(
                  "Are you sure you want to remove the user from this group?",
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
            onRemove(memberId);
          }
          Navigator.of(context).pop();
        });
        break;
      case MemberOption.makeAdmin:
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Make Admin?',
                ),
                content: new Text(
                  "Are you sure you want to this user admin?",
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
            onMakeAdmin(memberId);
          }
          Navigator.of(context).pop();
        });
        break;
    }
  }
}
