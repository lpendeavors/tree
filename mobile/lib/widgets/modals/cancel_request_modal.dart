import 'package:flutter/material.dart';

class CancelRequestModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Cancel Request?',
      ),
      content: Text("Are you sure you want to delete your connection request?"),
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