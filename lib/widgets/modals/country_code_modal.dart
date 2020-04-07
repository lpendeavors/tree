import 'package:flutter/material.dart';
import '../../models/country_list.dart';
import '../../models/country.dart';

class CountryCodeModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return AlertDialog(
      title: Text(
        'Country Code',
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context, "test");
          },
        ),
      ],
    );
  }
}