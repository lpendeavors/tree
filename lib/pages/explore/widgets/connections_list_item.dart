import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import '../explore_state.dart';

class ConnectionListItem extends StatefulWidget {
  final ConnectionItem connectionItem;

  const ConnectionListItem({
    @required this.connectionItem,
  });

  @override
  _ConnectionListItemState createState() => _ConnectionListItemState();
}

class _ConnectionListItemState extends State<ConnectionListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // TODO: view profile
      },
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // TODO: image holder
            SizedBox(width: 15),
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'name'
                            ),
                            
                          ],
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