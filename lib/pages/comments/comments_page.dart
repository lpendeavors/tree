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
import 'widgets/reply_screen.dart';

class CommentsPage extends StatefulWidget {
  final UserBloc userBloc;
  final CommentsBloc commentsBloc;

  const CommentsPage({
    Key key,
    @required this.userBloc,
    @required this.commentsBloc,
  }) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: false,
        title: Text(
          'Comments',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(12),
            child: RaisedButton(
              onPressed: () {},
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.notifications_off,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Unmuted',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.favorite,
          //     color: Theme.of(context).primaryColor,
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder<CommentsState>(
            stream: _commentsBloc.commentsState$,
            initialData: _commentsBloc.commentsState$.value,
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
                return Expanded(
                  // width: double.infinity,
                  // height: MediaQuery.of(context).size.height - 150,
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

              return Flexible(
                child: ListView.builder(
                  itemCount: data.comments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.bottomLeft,
                            children: <Widget>[
                              CommentListItem(
                                comment: data.comments[index],
                                onLike: (like) {
                                  _commentsBloc.commentToLikeChanged(
                                      data.comments[index].id);
                                  _commentsBloc.likeComment(like);
                                },
                                isPage: true,
                                isReply: false,
                                onReply: () {
                                  _commentsBloc.commentToLikeChanged(
                                    data.comments[index].id,
                                  );

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ReplyScreen(
                                        comment: data.comments[index],
                                        commentsBloc: _commentsBloc,
                                        userImage: (widget.userBloc.loginState$
                                                .value as LoggedInUser)
                                            .image,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Divider(height: 1),
          StreamBuilder<CommentsState>(
            stream: _commentsBloc.commentsState$,
            initialData: _commentsBloc.commentsState$.value,
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data.postDetails != null && data.postDetails.isMuted) {
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Comments have been disabled for this post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return CommentInput(
                userImage:
                    (widget.userBloc.loginState$.value as LoggedInUser).image,
                commentsBloc: _commentsBloc,
                isReply: false,
              );
            },
          ),
        ],
      ),
    );
  }
}
