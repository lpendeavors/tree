import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import 'package:smart_text_view/smart_text_view.dart';
import '../../util/asset_utils.dart';
import '../comments/widgets/comment_list_item.dart';
import '../../widgets/image_holder.dart';
import '../comments/comments_state.dart';
import '../feed/widgets/feed_list_item.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './post_details_bloc.dart';
import './post_details_state.dart';

class PostDetailsPage extends StatefulWidget {
  final UserBloc userBloc;
  final PostDetailsBloc Function() initPostDetailsBloc;

  const PostDetailsPage({
    Key key,
    @required this.userBloc,
    @required this.initPostDetailsBloc,
  }) : super(key: key);

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage>
    with TickerProviderStateMixin {
  PostDetailsBloc _postDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _postDetailsBloc = widget.initPostDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _postDetailsBloc.dispose();
    print('[DEBUG] _PostDetailsState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PostDetailsState>(
      stream: _postDetailsBloc.postDetailsState$,
      initialData: _postDetailsBloc.postDetailsState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        if (data.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (data.error != null) {
          print(data.error);
          return Center(
            child: Text(
              S.of(context).error_occurred,
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Post'),
          ),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      FeedListItem(
                        feedItem: data.postDetails,
                        context: context,
                        tickerProvider: this,
                        likeFeedItem: (id) => print(id),
                        isFeed: false,
                      ),
                      ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: data.commentItems.length,
                        padding: EdgeInsets.all(2),
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CommentListItem(
                                comment: data.commentItems[index],
                                isPage: false,
                                isReply: false,
                                onLike: null,
                                onReply: null,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
