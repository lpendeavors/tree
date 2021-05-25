import 'dart:async';

import 'package:flutter/material.dart';
import './report_state.dart';
import './report_bloc.dart';

class ReportPage extends StatefulWidget {
  final ReportBloc reportBloc;

  const ReportPage({
    Key key,
    @required this.reportBloc,
  }) : super(key: key);

  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  ReportBloc _reportBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _reportBloc = widget.reportBloc;
    _subscriptions = [];
  }

  void _showMessageResult(ReportMessage message) {
    print('[DEBUG] ReportMessage=$message');
  }

  @override
  void dispose() {
    print('[DEBUG] _ReportState#dispose');
    _reportBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          'Reports',
          style: TextStyle(
            fontSize: 17,
            color: Color(0xffff0000),
          ),
        ),
      ),
      body: Column(),
    );
  }
}
