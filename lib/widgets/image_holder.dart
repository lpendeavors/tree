import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageHolder extends StatelessWidget {
  final double size;
  final String image;

  const ImageHolder({
    @required this.size,
    @required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: <Widget>[
          Card(
            shape: CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            elevation: 0.5,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: size,
                  height: size,
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: size / 3,
                    ),
                  ),
                ),
                if (image.isNotEmpty) ...[
                  CachedNetworkImage(
                    imageUrl: image,
                    height: size,
                    width: size,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
