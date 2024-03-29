import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../generated/l10n.dart';
import '../../../util/event_utils.dart';
import '../events_state.dart';

class EventsListItem extends StatefulWidget {
  final EventItem eventItem;
  final Function() onDelete;
  final Function() onReport;
  final Function(int) onStatusUpdate;

  const EventsListItem({
    @required this.eventItem,
    @required this.onDelete,
    @required this.onReport,
    @required this.onStatusUpdate,
  });

  @override
  _EventsListItemState createState() => _EventsListItemState();
}

class _EventsListItemState extends State<EventsListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pushNamed(
          '/event_details',
          arguments: widget.eventItem.id,
        );
      },
      onLongPress: () {},
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xff14000000),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              // alignment: Alignment.bottomCenter,
              children: <Widget>[
                if (widget.eventItem.image != null)
                  CachedNetworkImage(
                    height: 250,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    colorBlendMode: BlendMode.darken,
                    imageUrl: widget.eventItem.image,
                  ),
                Container(
                  height: 300,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.eventItem.location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          padding: EdgeInsets.all(8),
                          child: Image.asset(
                            eventTypes[widget.eventItem.eventType].assetImage,
                            height: 15,
                            width: 15,
                            color:
                                eventTypes[widget.eventItem.eventType].useColor
                                    ? Colors.white
                                    : null,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.eventItem.isSponsored)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xffe8e8e8).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          S.of(context).event_sponsored_title,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    onPressed: () => _showEventOptions(context),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xff14000000),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          DateFormat('MMM').format(widget.eventItem.startDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          widget.eventItem.startDate.day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${DateFormat('jm').format(widget.eventItem.startDate)} ${widget.eventItem.title}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.eventItem.details,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // TODO: Add admin functionality
          ],
        ),
      ),
    );
  }

  Future<int> _showEventStatuses(BuildContext context) async {
    switch (await showDialog<EventStatus>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              'Tree',
            ),
            children: <Widget>[
              if (widget.eventItem.isAdmin) ...[
                SimpleDialogOption(
                  child: Text('Pending'),
                  onPressed: () => Navigator.pop(context, EventStatus.pending),
                ),
                SimpleDialogOption(
                  child: Text('Approved'),
                  onPressed: () => Navigator.pop(context, EventStatus.approved),
                ),
                SimpleDialogOption(
                  child: Text('Inactive'),
                  onPressed: () => Navigator.pop(context, EventStatus.inactive),
                ),
                SimpleDialogOption(
                  child: Text('Completed'),
                  onPressed: () => Navigator.pop(context, EventStatus.complete),
                ),
              ]
            ],
          );
        })) {
      case EventStatus.pending:
        return 0;
        break;
      case EventStatus.approved:
        return 1;
        break;
      case EventStatus.inactive:
        return 3;
        break;
      case EventStatus.complete:
        return 4;
        break;
      default:
        return null;
        break;
    }
  }

  Future<void> _showEventOptions(BuildContext context) async {
    switch (await showDialog<EventOption>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              'Tree',
            ),
            children: <Widget>[
              if (widget.eventItem.isMine || widget.eventItem.isAdmin) ...[
                SimpleDialogOption(
                  child: Text('Delete Event'),
                  onPressed: () => Navigator.pop(context, EventOption.delete),
                ),
              ],
              if (widget.eventItem.isMine) ...[
                SimpleDialogOption(
                  child: Text('Edit Event'),
                  onPressed: () => Navigator.pop(context, EventOption.edit),
                ),
              ],
              if (!widget.eventItem.isMine) ...[
                SimpleDialogOption(
                  child: Text('Report Event'),
                  onPressed: () => Navigator.pop(context, EventOption.report),
                ),
              ],
              if (widget.eventItem.isAdmin) ...[
                SimpleDialogOption(
                  child: Text('Change Status'),
                  onPressed: () =>
                      Navigator.pop(context, EventOption.changeStatus),
                ),
                SimpleDialogOption(
                  child: Text('Update Max Reach'),
                  onPressed: () =>
                      Navigator.pop(context, EventOption.updateReach),
                ),
              ]
            ],
          );
        })) {
      case EventOption.edit:
        Navigator.of(context).pushNamed(
          '/edit_event',
          arguments: <String, dynamic>{
            'eventId': widget.eventItem.id,
            'eventType': widget.eventItem.eventType,
          },
        );
        break;
      case EventOption.delete:
        widget.onDelete();
        break;
      case EventOption.report:
        print('report');
        break;
      case EventOption.updateReach:
        print('update reach');
        break;
      case EventOption.changeStatus:
        int result = await _showEventStatuses(context);
        if (result != null) {
          widget.onStatusUpdate(result);
        }
        break;
    }
  }
}
