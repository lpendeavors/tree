import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/pages/feed/feed_state.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import 'package:treeapp/widgets/image_holder.dart';

class PostSharePage extends StatelessWidget {
  final FeedItem feedItem;
  final LoginState loginState;

  const PostSharePage({
    Key key,
    @required this.feedItem,
    @required this.loginState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = loginState as LoggedInUser;
    var postController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context, null);
            }),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Text(
                "SHARE",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (postController.text.length > 0) {
                  Navigator.pop(context, postController.text);
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.topCenter,
                child: ListView(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ImageHolder(
                          size: 40,
                          image: user.image ?? "",
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                            child: TextField(
                          //focusNode: focusNode,
                          controller: postController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                              hintText: "Say something about this post....",
                              hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.7)),
                              border: InputBorder.none),
                        ))
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 15),
                          padding: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                                child: CachedNetworkImage(
                                  width: 100,
                                  height: 100,
                                  imageUrl: feedItem.userImage ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feedItem.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      feedItem.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
