import 'package:flutter/material.dart';

class CurvedScaffold extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final double curveRadius;
  final Color bgColor;
  final GlobalKey scaffoldKey;

  const CurvedScaffold({
    Key key,
    @required this.appBar,
    @required this.body,
    this.curveRadius = 20,
    this.scaffoldKey,
    this.bgColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6CA748),
              Color(0xFF6CA748),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            _scaffoldAppBar(),
            _scaffoldBody(),
          ],
        ),
      ),
    );
  }

  Widget _scaffoldAppBar() {
    return SafeArea(
      bottom: false,
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 5,
          top: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            appBar,
          ],
        ),
      ),
    );
  }

  Widget _scaffoldBody() {
    return Flexible(
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(curveRadius),
            topRight: Radius.circular(curveRadius),
          ),
          child: body),
        //padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 5,
              offset: Offset(0.5, 0.1))
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(curveRadius),
            topRight: Radius.circular(curveRadius),
          )),
      ),
    );
  }
}