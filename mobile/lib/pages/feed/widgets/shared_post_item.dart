import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:treeapp/models/old/user_entity.dart';
import '../feed_state.dart';

class SharedPostItem extends StatefulWidget {
  final FeedItem feedItem;
  final BuildContext context;
  final TickerProvider tickerProvider;

  const SharedPostItem({
    @required this.feedItem,
    @required this.context,
    @required this.tickerProvider,
  });

  @override
  _SharedPostItemState createState() => _SharedPostItemState();
}

class _SharedPostItemState extends State<SharedPostItem> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var _expanded = false;

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
        if (widget.feedItem.isShared) {
          Navigator.of(context).pushNamed(
            '/post_details',
            arguments: widget.feedItem.id,
          );
        }
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
                            return GestureDetector(
                              onTap: () {},
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
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
}
