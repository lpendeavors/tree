import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_text_view/smart_text_view.dart';
import '../../util/asset_utils.dart';
import '../../util/event_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './widgets/event_details_map.dart';
import './event_details_bloc.dart';
import './event_details_state.dart';

class EventDetailsPage extends StatefulWidget {
  final UserBloc userBloc;
  final EventDetailsBloc Function() initEventDetailsBloc;

  const EventDetailsPage({
    Key key,
    @required this.userBloc,
    @required this.initEventDetailsBloc,
  }) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  EventDetailsBloc _eventDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _eventDetailsBloc = widget.initEventDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _eventDetailsBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EventAttendeesMessage message) {
    print('[DEBUG] EventDetailsMessage=$message');
  }

  @override
  void dispose() {
    print('[DEBUG] _EventDetailsState#dispose');
    _subscriptions.forEach((s) => s.cancel());
    _eventDetailsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventDetailsState>(
      stream: _eventDetailsBloc.eventDetailsState$,
      initialData: _eventDetailsBloc.eventDetailsState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(S.of(context).event_details_title),
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                child: ListView(
                  padding: EdgeInsets.all(0),
                  children: <Widget>[
                    if (data.eventDetails != null) ...[
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Container(
                                child: CachedNetworkImage(
                                    imageUrl: data.eventDetails.image),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.9),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.1),
                                        Colors.black.withOpacity(0.9),
                                      ],
                                    )),
                              ),
                              if (data.eventDetails.attendees.length > 0) ...[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        S.of(context).event_attendees_title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: <Widget>[
                                          ...List.generate(
                                              data.eventDetails.attendees
                                                          .length <=
                                                      4
                                                  ? data.eventDetails.attendees
                                                      .length
                                                  : 4, (index) {
                                            if (data.eventDetails.attendees
                                                    .length ==
                                                4) {
                                              return Container(
                                                height: 50,
                                                width: 50,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.4),
                                                  shape: BoxShape.circle,
                                                ),
                                              );
                                            }
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                              child: AnimatedContainer(
                                                width: 50,
                                                height: 50,
                                                curve: Curves.ease,
                                                alignment: Alignment.center,
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                padding: EdgeInsets.all(0.5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Card(
                                                      elevation: 0.5,
                                                      margin: EdgeInsets.all(0),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      color: Colors.transparent,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: <Widget>[
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.event,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          if (data.eventDetails
                                                              .image.isNotEmpty)
                                                            CachedNetworkImage(
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                              imageUrl: data
                                                                  .eventDetails
                                                                  .image,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (data.eventDetails.isSponsored) ...[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xffe8e8e8).withOpacity(0.5),
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
                              ],
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.1),
                        margin: EdgeInsets.all(0),
                      ),
                      if (data.eventDetails.isMine &&
                          data.eventDetails.isRejected) ...[
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                S.of(context).event_rejected_reason_title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                data.eventDetails.reason,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (data.eventDetails.isMine &&
                          data.eventDetails.isSponsored)
                        ...[],
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    data.eventDetails.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  padding: EdgeInsets.all(8),
                                  child: Image.asset(
                                    eventTypes[data.eventDetails.type]
                                        .assetImage,
                                    height: 15,
                                    width: 15,
                                    color: eventTypes[data.eventDetails.type]
                                            .useColor
                                        ? Colors.white
                                        : null,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.place,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        data.eventDetails.location,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.event_note,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        eventTypes[data.eventDetails.type]
                                            .eventTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.attach_money,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        data.eventDetails.price
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (data
                                    .eventDetails.webAddress.isNotEmpty) ...[
                                  Container(
                                    height: 40,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.vpn_lock,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child: SmartText(
                                            text: data.eventDetails.webAddress,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              S.of(context).event_description_title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(data.eventDetails.details,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.7),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 150,
                            margin: EdgeInsets.only(left: 15, right: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage(google_map),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: 150,
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(left: 15, right: 15),
                            alignment: Alignment.topRight,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.9),
                                    ])),
                            child: RaisedButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(S.of(context).view_map),
                              onPressed: () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return EventDetailsMap(
                                      LatLng(
                                        data.eventDetails.latitude,
                                        data.eventDetails.longitude,
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ],
                ),
              ),
              if (data.eventDetails != null) ...[
                if (!data.eventDetails.isMine) ...[
                  RaisedButton(
                    color: data.eventDetails.isAttending
                        ? Color(0xffe94f4f)
                        : Theme.of(context).primaryColor,
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        data.eventDetails.isAttending
                            ? S.of(context).cancel
                            : S.of(context).event_attend_title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () {
                      _eventDetailsBloc
                          .toggleAttendance(!data.eventDetails.isAttending);
                    },
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
