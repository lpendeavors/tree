import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import '../notifications_state.dart';

class NotificationsListItem extends StatefulWidget {
  final NotificationItem notificationItem;

  const NotificationsListItem({
    @required this.notificationItem,
  });

  @override
  _NotificationsListItemState createState() => _NotificationsListItemState();
}

class _NotificationsListItemState extends State<NotificationsListItem>{
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {

      },
      onLongPress: () {

      },
      child: Opacity(
        opacity: widget.notificationItem.isNew != null ? .5 : 1,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {

                      },
                      child: AnimatedContainer(
                        curve: Curves.ease,
                        alignment: Alignment.center,
                        duration: Duration(
                          milliseconds: 300,
                        ),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Color(0xfff79836),
                          shape: BoxShape.circle,
                        ),
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: <Widget>[
                            Card(
                              margin: EdgeInsets.all(0),
                              shape: CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              color: Colors.transparent,
                              elevation: 0.5,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  if (widget.notificationItem.image != null)
                                    Image(
                                      fit: BoxFit.cover,
                                      image: CacheImage(widget.notificationItem.image),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.notificationItem.sharedBy,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ',
                                ),
                                TextSpan(
                                  text: widget.notificationItem.body,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.notificationItem.time,
                      style: TextStyle(

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}