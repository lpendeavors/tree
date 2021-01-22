import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/generated/l10n.dart';
import 'package:treeapp/models/old/post_entity.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/pages/comments/comments_state.dart';
import 'package:treeapp/pages/comments/widgets/comment_list_item.dart';
import 'package:treeapp/pages/connections/connections_state.dart';
import 'package:treeapp/pages/feed/feed_state.dart';
import 'package:treeapp/pages/feed/widgets/shared_post_item.dart';
import 'package:treeapp/widgets/image_holder.dart';
import 'package:treeapp/pages/connections/widgets/connection_list_item.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import './reported_users_bloc.dart';
import './reported_users_state.dart';

class ReportedUsersPage extends StatefulWidget {
  final UserBloc userBloc;
  final ReportedUsersBloc Function() initReportedUsersBloc;

  const ReportedUsersPage({
    Key key,
    @required this.userBloc,
    @required this.initReportedUsersBloc,
  }) : super(key: key);

  @override
  _ReportedUsersPageState createState() => _ReportedUsersPageState();
}

class _ReportedUsersPageState extends State<ReportedUsersPage>
    with TickerProviderStateMixin {
  List<StreamSubscription> _subscriptions;
  ReportedUsersBloc _reportedUsersBloc;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _reportedUsersBloc = widget.initReportedUsersBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.pushReplacementNamed(context, '/getting_started')),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _reportedUsersBloc.dispose();
    print('[DEBUG] _ReportedUsersPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<ReportedUsersState>(
        stream: _reportedUsersBloc.reportedUsersState$,
        initialData: _reportedUsersBloc.reportedUsersState$.value,
        builder: (context, snapshot) {
          var data = snapshot.data;

          if (data.error != null) {
            print(data.error);
            return Container(
              child: Center(
                child: Text(S.of(context).error_occurred),
              ),
            );
          }

          if (data.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (data.reports.isEmpty) {
            return Container();
          }

          return ListView.builder(
            itemCount: data.reports.length,
            itemBuilder: (context, index) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {},
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
                                                  if (data.reports[index]
                                                              .userImage !=
                                                          null &&
                                                      data.reports[index]
                                                          .userImage.isNotEmpty)
                                                    CachedNetworkImage(
                                                      imageUrl: data
                                                          .reports[index]
                                                          .userImage,
                                                      width: 50,
                                                      height: 50,
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
                                      Navigator.of(context).pushNamed(
                                        '/profile',
                                        arguments: data.reports[index].userId,
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: data
                                                    .reports[index].userName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 70),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text(
                              'Reason: ${data.reports[index].message}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    if (data.reports[index].post != null)
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: FutureBuilder<FeedItem>(
                          future: _getPost(data.reports[index].post),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.none &&
                                snapshot.hasData == null) {
                              return Container();
                            }

                            if (snapshot.hasData != null &&
                                snapshot.data != null) {
                              return SharedPostItem(
                                feedItem: snapshot.data,
                                context: context,
                                tickerProvider: this,
                              );
                            }

                            return Container();
                          },
                        ),
                      ),
                    if (data.reports[index].group != null)
                      Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Text('show group'),
                      ),
                    if (data.reports[index].comment != null)
                      Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Container(),
                      ),
                    if (data.reports[index].user != null)
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: FutureBuilder<ConnectionItem>(
                          future: _getUser(data.reports[index].user),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.none &&
                                snapshot.hasData == null) {
                              return Container();
                            }

                            if (snapshot.hasData != null &&
                                snapshot.data != null) {
                              return ConnectionListItem(
                                user: snapshot.data,
                              );
                            }

                            return Container();
                          },
                        ),
                      ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<ReportedGroup> _getGroup(
    String groupId,
  ) {}

  Future<CommentItem> _getComment(
    String commentId,
  ) {}

  Future<ConnectionItem> _getUser(
    String userId,
  ) async {
    var snapshot = await _firestore.doc('userBase/$userId').get();
    var entity = UserEntity.fromDocumentSnapshot(snapshot);
    return ConnectionItem(
      uid: entity.id,
      isChurch: entity.isChurch ?? false,
      photo: entity.image,
      aboutMe: entity.aboutMe ?? "Hey there! I am using Tree",
      churchName: entity.churchName,
      fullName: entity.fullName,
      id: entity.id,
    );
  }

  Future<FeedItem> _getPost(
    String postId,
  ) async {
    var snapshot = await _firestore.doc('postBase/$postId').get();
    var entity = PostEntity.fromDocumentSnapshot(snapshot);
    return FeedItem(
      id: null,
      tags: entity.tags,
      timePosted: DateTime.fromMillisecondsSinceEpoch(entity.time),
      timePostedString:
          timeago.format(DateTime.fromMillisecondsSinceEpoch(entity.time)),
      message: entity.postMessage,
      name: (entity.isChurch ?? false) ? entity.churchName : entity.fullName,
      userImage: entity.image,
      userId: entity.ownerId,
      isPoll: entity.type == PostType.poll.index,
      postImages: _getSharedImages(entity),
      isMine: false,
      isLiked: false,
      abbreviatedPost: entity.postMessage,
      isShared: entity.isShared ?? false,
      pollData: entity.pollData ?? [],
      likes: entity.likes ?? [],
      sharedPost: null,
      type: (entity.postData != null && entity.postData.isNotEmpty)
          ? entity.postData[0].type ?? 0
          : 0,
    );
  }

  List<String> _getSharedImages(PostEntity entity) {
    List<String> images = List<String>();

    if (entity.postData != null) {
      if (entity.postData.length > 0) {
        images = entity.postData.map((data) => data.imageUrl).toList();
      }
    }

    return images;
  }
}
