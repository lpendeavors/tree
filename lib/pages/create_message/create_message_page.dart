import 'dart:async';

import 'package:flutter/material.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
import '../../widgets/empty_list_view.dart';
import '../../widgets/image_holder.dart';
import './create_message_bloc.dart';
import './create_message_state.dart';

class CreateMessagePage extends StatefulWidget {
  final UserBloc userBloc;
  final CreateMessageBloc Function() initCreateMessageBloc;
  final List<MemberItem> existingMembers;

  const CreateMessagePage({
    Key key,
    @required this.userBloc,
    @required this.initCreateMessageBloc,
    @required this.existingMembers,
  }) : super(key: key);

  @override
  _CreateMessagePageState createState() => _CreateMessagePageState();
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  CreateMessageBloc _messageBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _messageBloc = widget.initCreateMessageBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _messageBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(MessageCreateMessage message) {
    if (message is MessageCreateSuccess) {
      if (widget.existingMembers != null && widget.existingMembers.length > 0) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(
          '/chat_room',
          arguments: message.details,
        );
      }
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _messageBloc.dispose();
    print('[DEBUG] _CreateMessagePageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _existingMembers = widget.existingMembers ?? List<MemberItem>();
    if (_existingMembers.length == 0) {
      var myInfo = widget.userBloc.loginState$.value as LoggedInUser;
      _messageBloc.membersChanged([
        MemberItem(
          id: myInfo.uid,
          image: myInfo.image ?? "",
          name: myInfo.fullName,
          token: myInfo.token,
          groupAdmin: true,
        ),
      ]);
    } else {
      _messageBloc.membersChanged(_existingMembers);
    }

    return WillPopScope(
      onWillPop: () async {
        // TODO confirm exit
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<int>(
                stream: _messageBloc.type$,
                initialData: _messageBloc.type$.value,
                builder: (context, snapshot) {
                  var type = snapshot.data;
                  return Text(
                    _existingMembers.length > 0
                        ? 'Edit Group'
                        : MessageType.values[type] == MessageType.group
                            ? 'New Group'
                            : 'New conversation',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  );
                },
              ),
              Text(
                'Add Connections',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                onPressed: () {
                  var type = _messageBloc.type$.value;
                  if (MessageType.values[type] == MessageType.group) {
                    var members = _messageBloc.members$.value;
                    Navigator.of(context).pushNamed(
                      '/create_group',
                      arguments: <String, dynamic>{
                        'groupId': null,
                        'members': members,
                      },
                    );
                  } else {
                    _messageBloc.submitCreateMessage();
                  }
                },
                child: StreamBuilder<List<MemberItem>>(
                  stream: _messageBloc.members$,
                  initialData: _messageBloc.members$.value,
                  builder: (context, snapshot) {
                    var members = snapshot.data ?? [];
                    return Text(
                      members.isEmpty ? 'ADD' : 'NEXT',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            if ((_messageBloc.members$.value ?? []).isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 0.5,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                child: StreamBuilder<List<MemberItem>>(
                  stream: _messageBloc.members$,
                  initialData: _messageBloc.members$.value ?? [],
                  builder: (context, snapshot) {
                    var members = snapshot.data ?? [];

                    if (members.isEmpty) {
                      return Container();
                    }

                    return Wrap(
                      spacing: 5,
                      runAlignment: WrapAlignment.start,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: List.generate(members.length, (index) {
                        return Chip(
                          avatar: ImageHolder(
                            size: 30,
                            image: members[index].image,
                          ),
                          label: Text(
                            members[index].name,
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              Divider(height: 25),
            ],
            // Padding(
            //   padding: EdgeInsets.only(
            //     left: 12,
            //     right: 12,
            //   ),
            //   child: RaisedButton(
            //     elevation: 0,
            //     color: Colors.grey[50],
            //     padding: EdgeInsets.only(
            //       top: 15,
            //       left: 10,
            //       right: 10,
            //       bottom: 15,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(25),
            //       side: BorderSide(
            //         width: 0.5,
            //         color: Colors.black.withOpacity(0.1),
            //       ),
            //     ),
            //     child: Row(
            //       children: <Widget>[
            //         Icon(
            //           Icons.search,
            //           size: 15,
            //           color: Colors.black.withOpacity(0.7),
            //         ),
            //         SizedBox(
            //           width: 10,
            //         ),
            //         Text(
            //           'Find connections on Tree',
            //           style: TextStyle(
            //             color: Colors.black.withOpacity(0.5),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // Divider(height: 25),
            Expanded(
              child: StreamBuilder<CreateMessageState>(
                stream: _messageBloc.createMessageState$,
                initialData: _messageBloc.createMessageState$.value,
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (data.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (data.error != null) {
                    print(data.error);
                    return Center(
                      child: Text(
                        S.of(context).error_occurred,
                      ),
                    );
                  }

                  if (data.myConnections.isEmpty) {
                    return EmptyListView(
                      icon: Icons.person,
                      title: 'No connections',
                      description: '~You have no connections~',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.myConnections.length,
                    // separatorBuilder: (context, index) {
                    //   return Container(
                    //     height: 0.5,
                    //     width: double.infinity,
                    //     color: Colors.grey[50],
                    //     margin: EdgeInsets.fromLTRB(80, 0, 10, 0),
                    //   );
                    // },
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _messageBloc.toggleMember(
                            MemberItem(
                              id: data.myConnections[index].id,
                              image: data.myConnections[index].image,
                              name: data.myConnections[index].name,
                              token: data.myConnections[index].token,
                              groupAdmin: false,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Row(
                                  children: <Widget>[
                                    ImageHolder(
                                      size: 50,
                                      image: data.myConnections[index].image,
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: Text(
                                                  data.myConnections[index]
                                                      .name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              // Container(
                                              //   margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                              //   padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                                              //   decoration: BoxDecoration(
                                              //     color: Color(0xff5c4eb2),
                                              //     borderRadius: BorderRadius.circular(25),
                                              //     border: Border.all(
                                              //       color: Color(0xfffff3f3f3),
                                              //       width: 1
                                              //     ),
                                              //   ),
                                              //   child: StreamBuilder<int>(
                                              //     stream: _messageBloc.type$,
                                              //     initialData: _messageBloc.type$.value,
                                              //     builder: (context, snapshot) {
                                              //       var type = snapshot.data;
                                              //       return Text(
                                              //         MessageType.values[type] == MessageType.group
                                              //          ? 'group'
                                              //          : 'member',
                                              //       );
                                              //     },
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            data.myConnections[index].about,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder<List<MemberItem>>(
                                stream: _messageBloc.members$,
                                initialData: _messageBloc.members$.value,
                                builder: (context, snapshot) {
                                  var members = snapshot.data ?? [];
                                  var ids = members.map((m) => m.id).toList();

                                  return Container(
                                    height: 25,
                                    width: 25,
                                    decoration: ids.contains(
                                            data.myConnections[index].id)
                                        ? BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0XFFe46514),
                                                Color(0XFFf79836),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          )
                                        : BoxDecoration(
                                            color: Colors.grey[100],
                                            border:
                                                Border.all(color: Colors.grey),
                                            shape: BoxShape.circle,
                                          ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
