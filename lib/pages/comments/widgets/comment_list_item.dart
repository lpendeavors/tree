import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../comments_state.dart';

class CommentListItem extends StatelessWidget {
  final CommentItem comment;
  final bool isPage;
  final bool isReply;

  const CommentListItem({
    @required this.comment,
    @required this.isPage,
    @required this.isReply,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // TODO: delete/edit
      },
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(18),
                  margin: EdgeInsets.only(
                    left: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        comment.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      comment.isGif
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image(
                                height: 150,
                                width: 250,
                                fit: BoxFit.cover,
                                image: CacheImage(comment.gif),
                              ),
                            )
                          : Text(
                              comment.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                if (isPage && !isReply)
                  Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          timeago.format(comment.datePosted),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Like',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (comment.replies.isNotEmpty)
                  ...List.generate(
                    comment.replies.length,
                    (index) {
                      return GestureDetector(
                        onLongPress: () {},
                        child: CommentListItem(
                          isPage: isPage,
                          isReply: true,
                          comment: comment.replies[index],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/profile',
                arguments: comment.userId,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                curve: Curves.ease,
                alignment: Alignment.center,
                duration: Duration(milliseconds: 300),
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(0),
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      elevation: 0.5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: 35,
                            height: 35,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (comment.image.isNotEmpty) ...[
                            Image(
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              image: CacheImage(comment.image),
                            ),
                          ],
                        ],
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
