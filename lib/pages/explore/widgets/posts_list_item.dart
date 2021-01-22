import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
        child: widget.postItem.type == 2
            ? Container()
            : CachedNetworkImage(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                imageUrl: widget.postItem.image,
              ),
      );
    } else {
      return Container();
    }
  }
}
