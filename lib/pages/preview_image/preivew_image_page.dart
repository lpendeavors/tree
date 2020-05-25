import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatelessWidget {
  final String imageURL;

  PreviewImage({
    Key key,
    this.imageURL
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Image(
              image: CacheImage(imageURL),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          )
        ],
      ),
    );
  }
}
