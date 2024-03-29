import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:treeapp/pages/events/events_state.dart';
import 'package:treeapp/pages/post_share/post_share_page.dart';
import 'package:treeapp/pages/settings/settings_state.dart';
import '../../util/asset_utils.dart';
import '../../widgets/curved_scaffold.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './widgets/feed_list_item.dart';
import './feed_bloc.dart';
import './feed_state.dart';

class FeedPage extends StatefulWidget {
  final UserBloc userBloc;
  final FeedBloc Function() initFeedBloc;

  const FeedPage({
    Key key,
    @required this.userBloc,
    @required this.initFeedBloc,
  }) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<StreamSubscription> _subscriptions;
  FeedBloc _feedBloc;

  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();

    _feedBloc = widget.initFeedBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.pushReplacementNamed(context, '/getting_started')),
      _feedBloc.message$.listen(_showMessageResult),
      _feedBloc.deleteMessage$.listen(_showMessageResult),
      _feedBloc.unconnectMessage$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(FeedMessage message) {
    print('[DEBUG] FeedItemLikeMessage=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _feedBloc.dispose();
    print('[DEBUG] _FeedPageState#dispose');

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_hasLoaded) {
      var user = widget.userBloc.loginState$.value;
      if (user is LoggedInUser) {
        if (user.isChurch && !user.isChurchUpdated) {
          Future.delayed(Duration.zero, () {
            Navigator.pushNamed(context, '/info',
                arguments: SettingsType.updateChurch);
          });
        }

        if (!user.isChurch && !user.isProfileUpdated) {
          Future.delayed(Duration.zero, () {
            Navigator.pushNamed(context, '/info',
                arguments: SettingsType.updatePersonal);
          });
        }

        _hasLoaded = true;
      }
    }

    return CurvedScaffold(
      appBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 70,
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.center,
                  icon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.event,
                        color: Colors.white,
                      ),
                      Text(
                        S.of(context).events,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/events', arguments: EventFilter.none);
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onLongPress: () {
              var user = widget.userBloc.loginState$.value;
              if (user is LoggedInUser && user.isAdmin) {
                Navigator.of(context).pushNamed('/admin_panel');
              }
            },
            child: Text(
              S.of(context).app_title,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontFamily: TrajanProBold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 70,
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                ),
                if (_feedBloc.feedListState$.value != null &&
                    _feedBloc.feedListState$.value.hasNotifications)
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder<FeedListState>(
          stream: _feedBloc.feedListState$,
          initialData: _feedBloc.feedListState$.value,
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

            if (data.feedItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    )
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: data.feedItems.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return FeedListItem(
                  isFeed: true,
                  admin: (widget.userBloc.loginState$.value as LoggedInUser)
                      .isAdmin,
                  context: context,
                  tickerProvider: this,
                  feedItem: data.feedItems[index],
                  likeFeedItem: (item) {
                    _feedBloc.postToLikeChanged(item);
                    _feedBloc.likePostChanged(!data.feedItems[index].isLiked);
                    _feedBloc.saveLikeValue();
                  },
                  deletePost: () =>
                      _feedBloc.deletePost(data.feedItems[index].id),
                  unconnect: () =>
                      _feedBloc.unconnect(data.feedItems[index].userId),
                  reportPost: () => Navigator.of(context).pushNamed(
                    '/report_post',
                    arguments: <String, String>{
                      'post': data.feedItems[index].id,
                      'user':
                          (widget.userBloc.loginState$.value as LoggedInUser)
                              .uid,
                    },
                  ),
                  share: (comment) async {
                    if (comment) {
                      String message = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return PostSharePage(
                            feedItem: data.feedItems[index],
                            loginState: widget.userBloc.loginState$.value,
                          );
                        }),
                      );
                      _feedBloc.share(data.feedItems[index], message);
                    } else {
                      _feedBloc.share(data.feedItems[index], null);
                    }
                  },
                  answerPoll: (answerIndex) async {
                    _feedBloc.answerPoll(
                      data.feedItems[index].id,
                      answerIndex,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
