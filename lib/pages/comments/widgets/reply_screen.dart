import 'package:flutter/material.dart';
import 'package:treeapp/pages/comments/widgets/comment_list_item.dart';
import 'package:treeapp/widgets/empty_list_view.dart';

import '../comments_bloc.dart';
import '../comments_state.dart';
import 'comment_input.dart';

class ReplyScreen extends StatelessWidget {
  final CommentItem comment;
  final CommentsBloc commentsBloc;
  final String userImage;

  const ReplyScreen({
    @required this.comment,
    @required this.commentsBloc,
    @required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        centerTitle: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Replies to ${comment.fullName}',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (comment.replies.isEmpty)
            Flexible(
              child: EmptyListView(
                icon: Icons.chat,
                title: 'No replies',
                description: '~This comment has not received any reply yet.~',
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                itemCount: comment.replies.length,
                itemBuilder: (context, index) {
                  return CommentListItem(
                    isPage: false,
                    isReply: false,
                    comment: comment.replies[index],
                    onLike: null,
                    onReply: null,
                  );
                },
              ),
            ),
          Divider(height: 1),
          CommentInput(
            isReply: true,
            commentsBloc: commentsBloc,
            userImage: userImage,
          ),
        ],
      ),
    );
  }
}
