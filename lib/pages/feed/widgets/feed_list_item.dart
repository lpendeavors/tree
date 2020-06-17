import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import '../../comments/comments_panel.dart';
import '../../comments/comments_bloc.dart';
import '../../../dependency_injection.dart';
import '../../../user_bloc/user_bloc.dart';
import '../../../bloc/bloc_provider.dart';
import '../feed_state.dart';

class FeedListItem extends StatelessWidget {
  final FeedItem feedItem;
  final Function(String) likeFeedItem;
  final BuildContext context;
  final TickerProvider tickerProvider;

  const FeedListItem({
    @required this.feedItem,
    @required this.likeFeedItem,
    @required this.context,
    @required this.tickerProvider,
  });

  @override
  Widget build(BuildContext context) {
    var _imagesController = PageController();
    var _currentPage = 0;

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
                                  Navigator.of(context).pushNamed(
                                    '/profile',
                                    arguments: feedItem.userId,
                                  );
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
                                                if (feedItem.userImage != null)
                                                  Image(
                                                    fit: BoxFit.cover,
                                                    image: CacheImage(feedItem.userImage),
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
                                    Navigator.of(context).pushNamed(
                                      '/profile',
                                      arguments: feedItem.userId,
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: feedItem.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              )
                                            ),
                                          ]
                                        ),
                                      ),
                                      Text(
                                        feedItem.timePostedString,
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
                              if (feedItem.isPoll) ...[
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
                            _showPostOptions();
                          },
                        ),
                      ],
                    ),
                  ),
                  if ((feedItem.message ?? "").isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: AnimatedSize(
                              vsync: tickerProvider,
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
                                      text: feedItem.message,
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
                  if (feedItem.postImages.length > 0) ...[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: feedItem.postImages.length == 1
                        ? GestureDetector(
                            onTap: () {
                              // TODO: preview image
                            },
                            child: Image(
                              image: CacheImage(feedItem.postImages[0] ?? ""),
                              alignment: Alignment.center,
                            ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Stack(
                              children: <Widget>[
                                PageView.builder(
                                  controller: _imagesController,
                                  itemCount: feedItem.postImages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // TODO: preview image/video
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          Image(
                                            image: CacheImage(feedItem.postImages[index]),
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
                                          feedItem.postImages.length,
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
                                      '${_currentPage+1}/${feedItem.postImages.length}',
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
                  if (feedItem.isPoll) ...[

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
                          color: !feedItem.isLiked
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                          textAlign: null, 
                          alignment: MainAxisAlignment.start,
                          onTap: () => likeFeedItem(feedItem.id),
                        ),
                        _feedButton(
                          title: 'Comment', 
                          icon: Icons.comment,
                          color: Colors.grey,
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
                                      postId: feedItem.id,
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
                          color: Colors.grey,
                          textAlign: TextAlign.left, 
                          alignment: MainAxisAlignment.end,
                          onTap: () => _showShareOptions(), 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _feedButton({
    @required String title,
    @required IconData icon,
    @required Function() onTap,
    @required TextAlign textAlign,
    @required MainAxisAlignment alignment,
    @required Color color,
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
                    color: color,
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

  Future<void> _showShareOptions() async {

  }

  Future<void> _showPostOptions() async {
    switch (await showDialog<PostOption>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Tree',
          ),
          children: <Widget>[
            if (feedItem.isMine) ...[
              SimpleDialogOption(
                child: Text('Edit Post'),
                onPressed: () => Navigator.pop(context, PostOption.edit),
              ),
              SimpleDialogOption(
                child: Text('Delete Post'),
                onPressed: () => Navigator.pop(context, PostOption.delete),
              ),
            ],
            if (!feedItem.isMine) ...[
              SimpleDialogOption(
                child: Text('Unconnect with this person'),
                onPressed: () => Navigator.pop(context, PostOption.unconnect),
              ),
              SimpleDialogOption(
                child: Text('Report this post'),
                onPressed: () => Navigator.pop(context, PostOption.report),
              ),
            ],
          ],
        );
      }
    )) {
      case PostOption.edit:
        print('edit');
      break;
      case PostOption.delete:
        print('delete');
      break;
      case PostOption.unconnect:
        print('unconnect');
      break;
      case PostOption.report:
        print('report');
      break;
    }
  }
}