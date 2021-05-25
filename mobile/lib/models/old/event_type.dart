import 'package:meta/meta.dart';

class EventType {
  String eventTitle;
  String eventDescription;
  String assetImage;
  bool useColor;
  int eventType;

  EventType({
    @required this.eventTitle,
    @required this.eventDescription,
    @required this.assetImage,
    @required this.useColor,
    @required this.eventType
  });
}