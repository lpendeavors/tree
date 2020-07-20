import 'package:cached_network_image/cached_network_image.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treeapp/pages/comments/comments_bloc.dart';
import 'package:treeapp/widgets/image_holder.dart';

class CommentInput extends StatefulWidget {
  final CommentsBloc commentsBloc;
  final String userImage;

  const CommentInput({
    @required this.commentsBloc,
    @required this.userImage,
  });

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  TextEditingController gifSearchController = TextEditingController();
  FocusNode _keyboardFocus = FocusNode();
  GiphyCollection gifImages;

  final client = GiphyClient(
    apiKey: 'ymaSNyZlKAGTtpsmUCktMfS6kYgaTsoM',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconTheme(
          data: IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
          child: Container(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.withOpacity(0),
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: <Widget>[
                  ImageHolder(
                    size: 30,
                    image: widget.userImage,
                  ),
                  Container(
                    child: IconButton(
                      icon: CircleAvatar(
                        child: Icon(
                          Icons.gif,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        _keyboardFocus.unfocus();
                        _loadGifs();

                        gifSearchController.text = '';

                        widget.commentsBloc.isGifChanged(
                          !widget.commentsBloc.isGif$.value,
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: StreamBuilder<bool>(
                      stream: widget.commentsBloc.isGif$,
                      initialData: widget.commentsBloc.isGif$.value,
                      builder: (context, snapshot) {
                        var isGif = snapshot.data ?? false;

                        if (isGif) {
                          return TextField(
                            focusNode: _keyboardFocus,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: gifSearchController,
                            decoration: InputDecoration(
                              hintText: 'Search for gif...',
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.8),
                              ),
                            ),
                          );
                        } else {
                          return TextField(
                            focusNode: _keyboardFocus,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: widget.commentsBloc.commentChanged,
                            decoration: InputDecoration(
                              hintText: 'Comment on post...',
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.8),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: widget.commentsBloc.isGif$,
                    initialData: widget.commentsBloc.isGif$.value,
                    builder: (context, snapshot) {
                      var isGif = snapshot.data ?? false;

                      return Container(
                        child: CupertinoButton(
                          child: isGif ? Text('Search') : Text('Send'),
                          onPressed: () async {
                            if (isGif) {
                              var query = gifSearchController.value.text;
                              var gifs = await client.search(query);

                              setState(() {
                                gifImages = gifs;
                              });
                            } else {
                              widget.commentsBloc.addComment();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        StreamBuilder<bool>(
          stream: widget.commentsBloc.isGif$,
          initialData: widget.commentsBloc.isGif$.value,
          builder: (context, snapshot) {
            var isGif = snapshot.data ?? false;

            if (isGif && (gifImages.data ?? []).isNotEmpty) {
              return Flexible(
                fit: FlexFit.loose,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  color: Colors.grey.withOpacity(0.05),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          widget.commentsBloc.gifChanged(
                            gifImages.data[index].images.original.url,
                          );
                          widget.commentsBloc.addComment();
                        },
                        child: CachedNetworkImage(
                          imageUrl: gifImages.data[index].images.original.url,
                          fit: BoxFit.cover,
                          placeholder: (context, string) => Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            return Container(
              height: 1,
            );
          },
        ),
      ],
    );
  }

  void _loadGifs() async {
    var gifs = await client.trending();
    setState(() {
      gifImages = gifs;
    });
  }
}
