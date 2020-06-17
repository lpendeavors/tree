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

class _PostDetailsPageState extends State<PostDetailsPage> with TickerProviderStateMixin {
  PostDetailsBloc _postDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _postDetailsBloc = widget.initPostDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
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
          body: Column(
            children: <Widget>[
              Flexible(
                child: ListView(
                  children: <Widget>[
                    FeedListItem(
                      feedItem: data.postDetails,
                      context: context,
                      tickerProvider: this,
                      likeFeedItem: (id) => print(id),
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
                            _commentItem(
                              item: data.commentItems[index],
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
        );
      },
    );
  }

  Widget _commentItem({
    CommentItem item,
  }) {
    return GestureDetector(
      onLongPress: () {
        // TODO: report comment
      },
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Stack(
                              alignment: Alignment.bottomLeft,
                              children: <Widget>[
                                if (!item.isGif)
                                  Container(
                                    padding: EdgeInsets.all(18),
                                    margin: EdgeInsets.only(left: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.fullName,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Flexible(
                                          child: Text(
                                            item.message,
                                            maxLines: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: EdgeInsets.all(18),
                                    margin: EdgeInsets.only(left: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.01),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.fullName,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image(
                                            width: 250,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            image: CacheImage(item.image),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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
                        arguments: item.owner,
                      );
                    },
                    child: AbsorbPointer(
                      absorbing: true,
                      child: ImageHolder(
                        size: 40,
                        image: item.image,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}