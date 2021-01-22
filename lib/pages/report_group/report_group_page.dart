import 'dart:async';

import 'package:flutter/material.dart';

import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import './report_group_bloc.dart';
import './report_group_state.dart';

class ReportGroupPage extends StatefulWidget {
  final UserBloc userBloc;
  final ReportGroupBloc Function() initReportGroupBloc;

  const ReportGroupPage({
    Key key,
    @required this.userBloc,
    @required this.initReportGroupBloc,
  }) : super(key: key);

  @override
  _ReportGroupPageState createState() => _ReportGroupPageState();
}

class _ReportGroupPageState extends State<ReportGroupPage> {
  ReportGroupBloc _reportGroupBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _reportGroupBloc = widget.initReportGroupBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _reportGroupBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(ReportGroupMessage message) {
    print('[DEBUG] ReportGroupMessage=$message');

    if (message is ReportGroupSuccess) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _reportGroupBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Icon(
                        Icons.keyboard_backspace,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Text(
                    'Report Group',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: _reportGroupBloc.saveReport,
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
            margin: EdgeInsets.only(top: 5),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: SingleChildScrollView(
                child: TextField(
                  onChanged: _reportGroupBloc.messageChanged,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Please tell us why?',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
