import 'dart:async';

import 'package:flutter/material.dart';
import '../../widgets/empty_list_view.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
import './comments_bloc.dart';
import './comments_state.dart';
import './widgets/comment_list_item.dart';
import './widgets/comment_input.dart';

class CommentsPanel extends StatefulWidget {
  final UserBloc userBloc;
  final CommentsBloc commentsBloc;

  const CommentsPanel({
    Key key,
    @required this.userBloc,
    @required this.commentsBloc,
  }) : super(key: key);

  @override
  _CommentsPanelState createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  CommentsBloc _commentsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _commentsBloc = widget.commentsBloc;
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _commentsBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(CommentAddedMessage message) {
    print('[DEBUG] CommentAddedMessage=$message');
  }

  @override
  void dispose() {
    print('[DEBUG] _CommentsState#dispose');
    _subscriptions.forEach((s) => s.cancel());
    _commentsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      resizeToAvoidBottomPadding: true,
      body: Stack(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.only(top: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        color: Colors.transparent,
                      ),
                    ),
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                        ),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pushNamed(
                                  '/comments',
                                  arguments: _commentsBloc
                                      .commentsState$.value.postDetails.id,
                                ),
                                child: Center(
                                  child: Text(
                                    'View comments fullscreen',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: StreamBuilder<CommentsState>(
                                  stream: _commentsBloc.commentsState$,
                                  initialData:
                                      _commentsBloc.commentsState$.value,
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

                                    if (data.comments.isEmpty) {
                                      return Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height -
                                                150,
                                        child: Center(
                                          child: EmptyListView(
                                            title: 'No comments',
                                            description:
                                                '~This post has not recieved any comment yet.~',
                                            icon: Icons.comment,
                                          ),
                                        ),
                                      );
                                    }

                                    return LayoutBuilder(
                                      builder: (context, box) {
                                        return ListView.builder(
                                            itemCount: data.comments.length,
                                            itemBuilder: (context, index) {
                                              return CommentListItem(
                                                comment: data.comments[index],
                                                isReply: false,
                                                isPage: false,
                                              );
                                            });
                                      },
                                    );
                                  },
                                ),
                              ),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Color(0xff14000000),
                              ),
                              CommentInput(
                                userImage: (widget.userBloc.loginState$.value
                                            as LoggedInUser)
                                        .image ??
                                    "",
                                commentsBloc: widget.commentsBloc,
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
          ),
        ],
      ),
    );
  }
}
