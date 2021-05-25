import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/pages/connections/connections_state.dart';

class ConnectionListItem extends StatelessWidget {
  final ConnectionItem user;

  const ConnectionListItem({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/profile', arguments: user.uid);
      },
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: ClipRRect(
                child: AnimatedContainer(
                  curve: Curves.ease,
                  alignment: Alignment.center,
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                      color: Colors.black26, shape: BoxShape.circle),
                  width: 60.0,
                  height: 60.0,
                  child: Stack(
                    children: <Widget>[
                      new Card(
                        margin: EdgeInsets.all(0),
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        elevation: 0.5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: 60.0,
                              height: 60.0,
                              child: Center(
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 14.0)),
                            ),
                            if (user.photo != null && user.photo.isNotEmpty)
                              CachedNetworkImage(
                                width: 60.0,
                                height: 60.0,
                                fit: BoxFit.cover,
                                imageUrl: user.photo,
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.0),
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          (user.isChurch ?? false)
                              ? user.churchName ?? user.id
                              : user.fullName ?? user.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (user.isChurch ?? false)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              church_icon,
                              height: 25.0,
                              width: 25.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        SizedBox(height: 5.0),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(user.aboutMe,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontFamily: 'Nirmala',
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                        )),
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
