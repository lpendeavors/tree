import 'package:flutter/material.dart';
import '../events_bloc.dart';

class EventsMap extends StatefulWidget {
  final EventsBloc bloc;

  const EventsMap({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  _EventsMapState createState() => _EventsMapState();
}

class _EventsMapState extends State<EventsMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
    );
  }
}