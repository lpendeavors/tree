import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import '../explore_state.dart';

class PostListItem extends StatefulWidget {
  final PostItem postItem;

  const PostListItem({
    @required this.postItem,
  });

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.postItem.image.isNotEmpty) {
      return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/post_details',
            arguments: widget.postItem.id,
          );
        },
        child: Image(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          image: CacheImage(widget.postItem.image),
        ),
      );
    } else {
      return Container();
    }
  }
}