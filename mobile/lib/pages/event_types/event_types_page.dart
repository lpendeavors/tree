import 'package:flutter/material.dart';
import '../../util/event_utils.dart';
import '../../generated/l10n.dart';

class EventTypesPage extends StatefulWidget {
  @override
  _EventTypesPageState createState() => _EventTypesPageState();
}

class _EventTypesPageState extends State<EventTypesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        centerTitle: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          S.of(context).create_event_title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 60),
        children: <Widget>[
          Container(
            height: 60,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(12),
            child: Text(
              S.of(context).event_objective_title,
              style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ...List.generate(
            eventTypes.length,
            (index) {
              return Column(
                children: <Widget>[
                  _itemBuilder(index),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _itemBuilder(
    int index
  ) {
    return InkWell(
      onTap: () => _selectType(index),
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              padding: EdgeInsets.all(10),
              child: Image.asset(
                eventTypes[index].assetImage,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                )
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    eventTypes[index].eventTitle,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    eventTypes[index].eventDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.navigate_next,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _selectType(int index) {
    Map<String, dynamic> editArgs = {
      'eventId': null,
      'eventType': index,
    };

    Navigator.of(context).pushNamed(
      '/edit_event',
      arguments: editArgs
    );
  }
}