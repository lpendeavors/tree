import 'dart:async';

import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _commentsBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(CommentAddedMessage message) {
    print('[DEBUG] CommentAddedMessage=$message');
  }

  @override
  void dispose() {
    print('[DEBUG] CommentsState#dispose');
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
                                onPressed: () => Navigator.pushNamed(context, '/comments'),
                                child: Center(
                                  child: Text(
                                    'View comments fullscreen',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: StreamBuilder<CommentsState>(
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
                                      return Container(
                                        width: double.infinity,
                                        height: MediaQuery.of(context).size.height - 150,
                                        child: Center(
                                          child: EmptyListView(
                                            title: 'No comments',
                                            description: '~This post has not recieved any comment yet.~',
                                            icon: Icons.comment,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      itemCount: data.comments.length,
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return CommentListItem(
                                          comment: data.comments[index],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            height: 2,
                                            width: MediaQuery.of(context).size.width,
                                          ),
                                        );
                                      }, 
                                    );
                                  },
                                ),
                              ),
                              Container(),
                              CommentInput(),
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