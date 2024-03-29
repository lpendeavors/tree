import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:treeapp/models/old/poll_data.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/pages/feed/widgets/shared_post_item.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/widgets/image_holder.dart';
import 'package:cached_video_player/cached_video_player.dart';
import '../../comments/comments_panel.dart';
import '../../comments/comments_bloc.dart';
import '../../../dependency_injection.dart';
import '../../../user_bloc/user_bloc.dart';
import '../../../bloc/bloc_provider.dart';
import '../feed_state.dart';

class FeedListItem extends StatefulWidget {
  final FeedItem feedItem;
  final Function(String) likeFeedItem;
  final BuildContext context;
  final TickerProvider tickerProvider;
  final Function() deletePost;
  final Function() reportPost;
  final Function() unconnect;
  final Function(bool) share;
  final Function(int) answerPoll;
  final bool admin;
  final bool isFeed;

  const FeedListItem({
    @required this.feedItem,
    @required this.likeFeedItem,
    @required this.context,
    @required this.tickerProvider,
    @required this.deletePost,
    @required this.reportPost,
    @required this.unconnect,
    @required this.admin,
    @required this.isFeed,
    @required this.share,
    @required this.answerPoll,
  });

  @override
  _FeedListItemState createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> with RouteAware {
  var _expanded = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CachedVideoPlayerController _controller;

  @override
  initState() {
    super.initState();

    if (widget.feedItem.type == 2) {
      _controller =
          CachedVideoPlayerController.network(widget.feedItem.postImages[0])
            ..initialize().then((_) {
              setState(() {});
            });
    }
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

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
          arguments: widget.feedItem.id,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          decoration: BoxDecoration(
            color: widget.feedItem.isShared
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
                              if (!widget.feedItem.isMine) {
                                Navigator.of(context).pushNamed(
                                  '/profile',
                                  arguments: widget.feedItem.userId,
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
                                            if (widget.feedItem.userImage !=
                                                    null &&
                                                widget.feedItem.userImage
                                                    .isNotEmpty)
                                              CachedNetworkImage(
                                                imageUrl:
                                                    widget.feedItem.userImage,
                                                width: widget.feedItem.isShared
                                                    ? 40
                                                    : 50,
                                                height: widget.feedItem.isShared
                                                    ? 40
                                                    : 50,
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
                                if (widget.feedItem.tags.isNotEmpty) {
                                  // Tag screen
                                }

                                if (!widget.feedItem.isMine) {
                                  Navigator.of(context).pushNamed(
                                    '/profile',
                                    arguments: widget.feedItem.userId,
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if ((widget.feedItem.tags ?? []).isEmpty)
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: widget.feedItem.name,
                                            style: TextStyle(
                                              fontSize: widget.feedItem.isShared
                                                  ? 12
                                                  : 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    FutureBuilder<String>(
                                      initialData: '',
                                      future:
                                          _getTaggedUsers(widget.feedItem.tags),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.none &&
                                            snapshot.hasData == null) {
                                          return Container();
                                        }

                                        if (snapshot.hasData != null &&
                                            snapshot.data != null) {
                                          return Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${widget.feedItem.name} ${snapshot.data}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.feedItem.isShared
                                                            ? 12
                                                            : 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        return Container();
                                      },
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
                        _showPostOptions();
                      },
                    ),
                  ],
                ),
              ),
              if ((widget.feedItem.message ?? "").isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: AnimatedSize(
                          vsync: widget.tickerProvider,
                          duration: Duration(
                            milliseconds: 500,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _expanded = !_expanded;
                              setState(() {});
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SmartText(
                                  text: _expanded
                                      ? widget.feedItem.message
                                      : widget.feedItem.abbreviatedPost,
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
                                if (widget.feedItem.message !=
                                    widget.feedItem.abbreviatedPost)
                                  Text(
                                    _expanded ? 'Read Less' : 'Read More',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
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
              if (widget.feedItem.isShared &&
                  widget.feedItem.sharedPost != null) ...[
                SharedPostItem(
                  tickerProvider: widget.tickerProvider,
                  feedItem: widget.feedItem.sharedPost,
                  context: context,
                ),
              ],
              if (widget.feedItem.postImages.length > 0) ...[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: widget.feedItem.postImages.length == 1
                      ? GestureDetector(
                          onTap: () {
                            if (widget.feedItem.type == 2) {
                              _controller.setLooping(true);
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            }
                          },
                          child: (widget.feedItem.type == 2 &&
                                  _controller != null)
                              ? _controller.value.initialized
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: CachedVideoPlayer(_controller),
                                        ),
                                        _controller.value.isPlaying
                                            ? Container()
                                            : Icon(
                                                Icons.play_arrow_rounded,
                                                size: 200,
                                                color: Colors.grey[200],
                                              ),
                                      ],
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 300,
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                        ),
                                        CircularProgressIndicator(),
                                      ],
                                    )
                              : CachedNetworkImage(
                                  imageUrl: widget.feedItem.postImages[0] ?? "",
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
                                        widget.feedItem.type == 2
                                            ? Container
                                            : CachedNetworkImage(
                                                imageUrl: widget
                                                    .feedItem.postImages[index],
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
                                    '${_currentPage + 1}/${widget.feedItem.postImages.length}',
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
                          widget.feedItem.pollData.length,
                          (index) {
                            List<String> pollAnswers = [];
                            widget.feedItem.pollData.forEach((p) {
                              pollAnswers.addAll(p.answerResponse ?? []);
                            });

                            bool answered =
                                pollAnswers.contains(widget.feedItem.userId);

                            return GestureDetector(
                              onTap: () {
                                if (!answered) {
                                  widget.answerPoll(index);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            height: 25,
                                            width: 25,
                                            child: Center(
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: widget
                                                        .feedItem
                                                        .pollData[index]
                                                        .isAnswer
                                                    ? Colors.white
                                                    : Colors.white
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(widget.feedItem.pollData[index]
                                              .answerTitle),
                                        ],
                                      ),
                                    ),
                                    if (answered || widget.feedItem.isMine) ...[
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            child: LinearProgressIndicator(
                                              value: _getProgress(
                                                  (widget
                                                              .feedItem
                                                              .pollData[index]
                                                              .answerResponse ??
                                                          [])
                                                      .length,
                                                  (pollAnswers ?? []).length),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          height: 40,
                                          padding: EdgeInsets.all(8),
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            _getPercentage(
                                                widget.feedItem.pollData[index],
                                                pollAnswers),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (widget.feedItem.isMine &&
                            widget.feedItem.pollData
                                .map((p) =>
                                    (p.answerResponse ?? []).map((r) => r))
                                .toList()
                                .isNotEmpty)
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            onPressed: () {
                              List<String> responders = [];

                              widget.feedItem.pollData.forEach((p) => p
                                  .answerResponse
                                  .forEach((r) => responders.add(r)));

                              Navigator.of(context).pushNamed(
                                  '/poll_responders',
                                  arguments: <String, dynamic>{
                                    'pollId': widget.feedItem.id,
                                    'responders': responders,
                                  });
                            },
                            child: Center(
                              child: Text('View Results'),
                            ),
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
                  top: 5,
                  bottom: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _feedButton(
                      title: widget.feedItem.isMine
                          ? '${widget.feedItem.likes.length} likes'
                          : 'Like',
                      icon: Icons.favorite,
                      color: !widget.feedItem.isLiked
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      textAlign: null,
                      alignment: MainAxisAlignment.start,
                      onTap: () => widget.likeFeedItem(widget.feedItem.id),
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
                                    postId: widget.feedItem.id,
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
              if (widget.isFeed)
                FutureBuilder<LastCommentItem>(
                  future: _getLastComment(widget.feedItem.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.none &&
                        snapshot.hasData == null) {
                      return Container();
                    }

                    if (snapshot.hasData != null && snapshot.data != null) {
                      var comment = snapshot.data;
                      return Flexible(
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(18),
                                        margin: EdgeInsets.only(left: 28),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              comment.ownerName ?? '',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Flexible(
                                              child: Text(
                                                comment.comment ?? '',
                                                maxLines: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/profile',
                                  arguments: comment.ownerId,
                                );
                              },
                              child: AbsorbPointer(
                                absorbing: true,
                                child: ImageHolder(
                                  image: comment.ownerImage ?? '',
                                  size: widget.feedItem.isShared ? 40 : 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container();
                  },
                ),
              Container(
                height: 10,
                color: Color(0xff14000000),
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

  String _getPercentage(
    PollData pollData,
    List<String> pollAnswers,
  ) {
    var value = '0%';
    if ((pollData.answerResponse ?? []).length > 0 &&
        (pollAnswers ?? []).length > 0)
      return '${((pollData.answerResponse.length / pollAnswers.length) * 100).round()}%';

    return value;
  }

  double _getProgress(
    int responsesAmount,
    int totalAnswersAmount,
  ) {
    if (responsesAmount > 0 && totalAnswersAmount > 0)
      return responsesAmount / totalAnswersAmount;

    return 0;
  }

  Future<LastCommentItem> _getLastComment(String postId) async {
    var snapshots = await _firestore
        .collection('commentsBase')
        .where('postId', isEqualTo: postId)
        .orderBy('time')
        .get();

    var doc = snapshots.docs.last;

    return LastCommentItem(
      id: doc.id,
      ownerImage: doc['image'] ?? "",
      ownerId: doc['ownerId'],
      ownerName: doc['fullName'] ?? doc['churchName'],
      comment: doc['postMessage'],
    );
  }

  Future<String> _getTaggedUsers(
    List<String> userIds,
  ) async {
    List<UserEntity> users = [];

    for (final id in userIds) {
      var snapshot = await _firestore.doc('userBase/$id').snapshots().first;
      var userEntity = UserEntity.fromDocumentSnapshot(snapshot);
      users.add(userEntity);
    }

    List<String> usersNames = [];
    users.forEach((u) {
      var church = u.isChurch ?? false;
      if (church) {
        usersNames.add(u.churchName);
      } else {
        usersNames.add(u.fullName);
      }
    });

    var usersString = 'is with';

    for (var i = 0; i < usersNames.length; i++) {
      if (users.length == 1) {
        usersString = '$usersString ${usersNames[i]}';
      } else {
        if (i == usersNames.length - 1) {
          usersString = '$usersString and ${usersNames[i]}';
        } else {
          if (usersString == 'is with') {
            usersString = '$usersString ${usersNames[i]}';
          } else {
            usersString = '$usersString, ${usersNames[i]}';
          }
        }
      }
    }

    return usersString;
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
    switch (await showDialog<ShareOption>(
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
                              SimpleDialogOption(
                                child: Text('Say something about post'),
                                onPressed: () => Navigator.pop(
                                    context, ShareOption.withComment),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
                              ),
                              SimpleDialogOption(
                                child: Text('Just share on my wall'),
                                onPressed: () => Navigator.pop(
                                    context, ShareOption.withoutComment),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.1),
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
          );
        })) {
      case ShareOption.withComment:
        widget.share(true);
        break;
      case ShareOption.withoutComment:
        widget.share(false);
        break;
    }
  }

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
                              if (widget.feedItem.isMine) ...[
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
                              if (!widget.feedItem.isMine) ...[
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
        if (widget.feedItem.isPoll) {
          Navigator.of(context).pushNamed(
            '/edit_poll',
            arguments: <String, dynamic>{
              "pollId": widget.feedItem.id,
              "groupId": widget.feedItem.id,
            },
          );
        } else {
          Navigator.of(context).pushNamed(
            '/edit_post',
            arguments: <String, dynamic>{
              "postId": widget.feedItem.id,
              "groupId": widget.feedItem.id,
            },
          );
        }
        break;
      case PostOption.delete:
        widget.deletePost();
        break;
      case PostOption.unconnect:
        widget.unconnect();
        break;
      case PostOption.report:
        widget.reportPost();
        break;
      case PostOption.deleteUser:
        print('delete');
        break;
      case PostOption.suspendUser:
        print('suspend');
        break;
    }
  }
}
