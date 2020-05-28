import 'package:flutter/material.dart';
import '../../models/country_list.dart';
import '../../models/country.dart';

class LogoutModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Logout?',
      ),
      content: new Text("Are you sure you want to logout of your account?"),
      actions: <Widget>[
        FlatButton(
          child: Text('NO', style: TextStyle(color: Theme.of(context).primaryColor)),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text('YES', style: TextStyle(color: Colors.grey)),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}