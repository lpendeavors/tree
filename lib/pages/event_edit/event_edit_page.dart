import 'dart:async';

import '../../util/asset_utils.dart';
import '../../util/event_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './event_edit_bloc.dart';
import './event_edit_state.dart';
import 'package:flutter/material.dart';

class EventEditPage extends StatefulWidget {
  final UserBloc userBloc;
  final EventEditBloc Function() initEventEditBloc;
  final int eventType;

  const EventEditPage({
    Key key,
    @required this.userBloc,
    @required this.initEventEditBloc,
    this.eventType,
  }) : super(key: key);

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  EventEditBloc _eventEditBloc;
  List<StreamSubscription> _subscriptions;

  bool _wantsSponsorship =  false;
  bool _showEstimate = false;

  @override
  void initState() {
    super.initState();

    _eventEditBloc = widget.initEventEditBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _eventEditBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EventEditedMessage message) {
    print('[DEBUG] EventEditedMessage=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _eventEditBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return StreamBuilder(
      stream: _eventEditBloc.eventEditState$,
      initialData: _eventEditBloc.eventEditState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data as EventEditState;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            centerTitle: false,
            elevation: 1,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Text(
              eventTypes[
                widget.eventType
              ].eventTitle,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    data.eventDetails == null
                     ? s.event_create_title
                     : s.event_save_title,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _eventEditBloc.saveEvent,
                ),
              ),
            ],
          ),
          body: ListView(
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // TODO: add image layer
                    RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 20,
                            child: Icon(
                              Icons.camera_alt,
                              size: 15,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            s.event_add_photos,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        // TODO: add image picker
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: _eventEditBloc.titleChanged,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                      decoration: InputDecoration(
                        hintText: s.event_title,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.timer,
                                color: Colors.black,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_start_end_date,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          GestureDetector(
                            onTap: () async {
                              // TODO: DateTimeRangePicker
                            },
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Start date",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black.withOpacity(1),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Start time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black.withOpacity(1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'End date',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black.withOpacity(1),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'End time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black.withOpacity(1),
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
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.event_note,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.describe_event,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          TextField(
                            onChanged: _eventEditBloc.descriptionChanged,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: s.event_details_hint,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.link,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_destination_link,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          TextField(
                            onChanged: _eventEditBloc.webAddressChanged,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: s.event_web_address,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.attach_money,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_cost_label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          TextField(
                            onChanged: _eventEditBloc.costChanged,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_venue_label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          ListTile(
                            onTap: () async {
                              // TODO: pick location
                            },
                            title: Text(
                              s.event_venue_hint,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SwitchListTile(
                        value: _wantsSponsorship,
                        activeColor: Colors.blue[900],
                        title: Text(
                          s.event_sponsored_hint,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _wantsSponsorship = true;
                          });
                        },
                      ),
                    ),
                    if (_showEstimate) ...[
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              s.event_estimate_label,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Text(
                                  'sponsor reach',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Image.asset(friends, height: 25),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_wantsSponsorship) ...[
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            s.event_budget_label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: show budget message
                            },
                            child: Icon(
                              Icons.help,
                              size: 25,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      TextField(
                        onChanged: _eventEditBloc.budgetChanged,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}