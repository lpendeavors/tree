import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import '../../../util/asset_utils.dart';
import '../../../widgets/image_holder.dart';
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
            ImageHolder(
              size: 60,
              image: widget.connectionItem.image ?? "",
            ),
            SizedBox(width: 15),
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.connectionItem.name,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        if (widget.connectionItem.isChurch) ...[
                          ImageHolder(
                            size: 25,
                            image: church_icon,
                          ),
                          SizedBox(height: 5),
                        ],
                      ]
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Denomination',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Church denomination',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    if (!widget.connectionItem.isChurch) ...[
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              church_icon,
                              height: 12,
                              width: 12,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            SizedBox(width: 5),
                            Text(
                              widget.connectionItem.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Church addy or user city',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onPressed: () {
                              // TODO: 
                            },
                            child: Center(
                              child: Text(
                                'Connect',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onPressed: () {
                              // TODO
                            },
                            child: Center(
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
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