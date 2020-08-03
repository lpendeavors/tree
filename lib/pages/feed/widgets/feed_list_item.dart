import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:treeapp/util/asset_utils.dart';
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

    return // Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // children: <Widget>[
        GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/post_details',
          arguments: feedItem.id,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          decoration: BoxDecoration(
            color: feedItem.isShared
                ? Colors.black.withOpacity(0.01)
                : Colors.white,
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
                              if (!feedItem.isMine) {
                                Navigator.of(context).pushNamed(
                                  '/profile',
                                  arguments: feedItem.userId,
                                );
                              }
                            },
                            child: AbsorbPointer(
                              child: GestureDetector(
                                onTap: () {},
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
                                              CachedNetworkImage(
                                                imageUrl: feedItem.userImage,
                                                width:
                                                    feedItem.isShared ? 40 : 50,
                                                height:
                                                    feedItem.isShared ? 40 : 50,
                                                fit: BoxFit.cover,
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
                                if (feedItem.tags.isNotEmpty) {
                                  // Tag screen
                                }

                                if (!feedItem.isMine) {
                                  Navigator.of(context).pushNamed(
                                    '/profile',
                                    arguments: feedItem.userId,
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                          text: feedItem.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ]),
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
                            onTap: () {},
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
                          child: CachedNetworkImage(
                            imageUrl: feedItem.postImages[0],
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
                                        CachedNetworkImage(
                                          imageUrl: feedItem.postImages[index],
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
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
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
                                    '${_currentPage + 1}/${feedItem.postImages.length}',
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...List.generate(
                          feedItem.pollData.length,
                          (index) {
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
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
                                    userBloc:
                                        BlocProvider.of<UserBloc>(context),
                                    commentRepository:
                                        Injector.of(context).commentRepository,
                                    postRepository:
                                        Injector.of(context).postRepository,
                                    postId: feedItem.id,
                                  ),
                                );
                              }),
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
    ); //,
    //     SizedBox(height: 20),
    //   ],
    // );
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

  Future<void> _showShareOptions() async {}

  Future<void> _showPostOptions() async {
    switch (await showDialog<PostOption>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 140,
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
                          maxHeight: 90,
                        ),
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              SizedBox(height: 5),
                              if (feedItem.isMine) ...[
                                SimpleDialogOption(
                                  child: Text('Edit Post'),
                                  onPressed: () =>
                                      Navigator.pop(context, PostOption.edit),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SizedBox(height: 5),
                                SimpleDialogOption(
                                  child: Text('Delete Post'),
                                  onPressed: () =>
                                      Navigator.pop(context, PostOption.delete),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
                              if (!feedItem.isMine) ...[
                                SimpleDialogOption(
                                  child: Text('Unconnect with this person'),
                                  onPressed: () => Navigator.pop(
                                      context, PostOption.unconnect),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SimpleDialogOption(
                                  child: Text('Report this post'),
                                  onPressed: () =>
                                      Navigator.pop(context, PostOption.report),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
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
      case PostOption.edit:
        if (feedItem.isPoll) {
          Navigator.of(context).pushNamed(
            '/edit_poll',
            arguments: feedItem.id,
          );
        } else {
          Navigator.of(context).pushNamed(
            '/edit_post',
            arguments: feedItem.id,
          );
        }
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
