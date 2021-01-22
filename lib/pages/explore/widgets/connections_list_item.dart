import 'package:flutter/material.dart';
import '../../../util/asset_utils.dart';
import '../../../widgets/image_holder.dart';
import '../explore_state.dart';

class ConnectionListItem extends StatefulWidget {
  final ConnectionItem connectionItem;
  final Function(ConnectionItem) onRemove;
  final Function(ConnectionItem) onConnect;
  final Function(ConnectionItem) onAccept;
  final Function(ConnectionItem) onDecline;
  final bool isRequest;

  const ConnectionListItem({
    @required this.connectionItem,
    @required this.onRemove,
    @required this.onConnect,
    @required this.onAccept,
    @required this.onDecline,
    @required this.isRequest,
  });

  @override
  _ConnectionListItemState createState() => _ConnectionListItemState();
}

class _ConnectionListItemState extends State<ConnectionListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).pushNamed(
          '/profile',
          arguments: widget.connectionItem.id,
        );
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
                            widget.connectionItem.name ?? "",
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          if (widget.connectionItem.isChurch) ...[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Image.asset(
                                  church_icon,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ]),
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
                            widget.connectionItem.denomination ?? "None",
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
                              widget.connectionItem.church ?? "None",
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
                              widget.connectionItem.city,
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
                        if (widget.connectionItem.requested)
                          Flexible(
                            child: Center(
                              child: Text(
                                'Request pending',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          Flexible(
                            child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onPressed: () {
                                if (widget.isRequest) {
                                  widget.onAccept(widget.connectionItem);
                                } else {
                                  widget.onConnect(widget.connectionItem);
                                }
                              },
                              child: Center(
                                child: Text(
                                  widget.isRequest ? 'Accept' : 'Connect',
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
                                if (widget.isRequest) {
                                  widget.onDecline(widget.connectionItem);
                                } else {
                                  widget.onRemove(widget.connectionItem);
                                }
                              },
                              child: Center(
                                child: Text(
                                  widget.isRequest ? 'Decline' : 'Remove',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
