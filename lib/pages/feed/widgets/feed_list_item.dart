import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import '../../comments/comments_panel.dart';
import '../../comments/comments_bloc.dart';
import '../../../dependency_injection.dart';
import '../../../user_bloc/user_bloc.dart';
import '../../../bloc/bloc_provider.dart';
import '../feed_state.dart';

class FeedListItem extends StatefulWidget {
  final FeedItem feedItem;

  const FeedListItem({
    @required this.feedItem,
  });

  @override
  _FeedListItemState createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> with TickerProviderStateMixin {
  var _imagesController = PageController();
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {

          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.01),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withOpacity(0.04),
                  width: 0.6,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  // TODO: navigate to profile
                                },
                                child: AbsorbPointer(
                                  child: GestureDetector(
                                    onTap: () {

                                    },
                                    child: AnimatedContainer(
                                      curve: Curves.ease,
                                      alignment: Alignment.center,
                                      duration: Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: Color(0xfff79836),
                                        shape: BoxShape.circle,
                                      ),
                                      width: 50,
                                      height: 50,
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
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                                if (widget.feedItem.userImage != null)
                                                  Image(
                                                    fit: BoxFit.cover,
                                                    image: CacheImage(widget.feedItem.userImage),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {

                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: widget.feedItem.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              )
                                            ),
                                          ]
                                        ),
                                      ),
                                      Text(
                                        widget.feedItem.timePostedString,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              if (widget.feedItem.isPoll) ...[
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Poll',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                          ),
                          onPressed: () {
                            // TODO: Post menu
                          },
                        ),
                      ],
                    ),
                  ),
                  if (widget.feedItem.message.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: AnimatedSize(
                              vsync: this,
                              duration: Duration(
                                milliseconds: 500,
                              ),
                              child: GestureDetector(
                                onTap: () {

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SmartText(
                                      text: widget.feedItem.message,
                                      onTagClick: (tag) {
                                        // TODO: hash tag screen
                                      },
                                      onOpen: (url) {
                                        // TODO: show url
                                      },
                                      tagStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.feedItem.postImages.length > 0) ...[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: widget.feedItem.postImages.length == 1
                        ? GestureDetector(
                            onTap: () {
                              // TODO: preview image
                            },
                            child: Image(
                              image: CacheImage(widget.feedItem.postImages[0]),
                              alignment: Alignment.center,
                            ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Stack(
                              children: <Widget>[
                                PageView.builder(
                                  controller: _imagesController,
                                  itemCount: widget.feedItem.postImages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // TODO: preview image/video
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          Image(
                                            image: CacheImage(widget.feedItem.postImages[index]),
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SafeArea(
                                    bottom: false,
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List<Widget>.generate(
                                          widget.feedItem.postImages.length,
                                          (int index) {
                                            if (index == _currentPage) {
                                              return Container(
                                                height: 4,
                                                width: 4,
                                                margin: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              );
                                            }

                                            return Container(
                                              height: 4,
                                              width: 4,
                                              margin: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                            );
                                          }
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: EdgeInsets.all(15),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      '${_currentPage+1}/${widget.feedItem.postImages.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ],
                  if (widget.feedItem.isPoll) ...[

                  ],
                  Padding(
                    padding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _feedButton(
                          title: 'Like', 
                          icon: Icons.favorite,
                          textAlign: null, 
                          alignment: MainAxisAlignment.start,
                          onTap: null, 
                        ),
                        _feedButton(
                          title: 'Comment', 
                          icon: Icons.comment,
                          textAlign: null, 
                          alignment: MainAxisAlignment.center,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (context, _, __) {
                                  return CommentsPanel(
                                    userBloc: BlocProvider.of<UserBloc>(context),
                                    commentsBloc: CommentsBloc(
                                      userBloc: BlocProvider.of<UserBloc>(context),
                                      commentRepository: Injector.of(context).commentRepository,
                                      postId: widget.feedItem.id,
                                    ),
                                  );
                                }
                              ),
                            );
                          }, 
                        ),
                        _feedButton(
                          title: 'Share', 
                          icon: Icons.share,
                          textAlign: TextAlign.left, 
                          alignment: MainAxisAlignment.end,
                          onTap: null, 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedButton({
    @required String title,
    @required IconData icon,
    @required Function() onTap,
    @required TextAlign textAlign,
    @required MainAxisAlignment alignment,
  }) {
    return Flexible(
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: alignment,
            children: <Widget>[
              Container(
                height: 40,
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 3,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}