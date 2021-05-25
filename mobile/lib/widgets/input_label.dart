import 'package:flutter/material.dart';

class TreeInputLabel extends StatelessWidget {
  final String text;

  TreeInputLabel({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'NirmalaB',
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(0.4),
        fontSize: 12,
      ),
    );
  }
}