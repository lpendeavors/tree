import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextInputType inputType;
  final IconData icon;
  final bool hasIcon;
  final bool autofocus;
  final String hintText;

  InputField({
    Key key,
    @required this.inputType,
    @required this.hintText,
    this.autofocus = false,
    this.hasIcon = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (hasIcon) ...[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Icon(
              icon,
              size: 23,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ],
        Flexible(
          child: TextField(
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.none,
            autofocus: autofocus,
            cursorColor: Colors.black,
            cursorWidth: 1,
            maxLines: 1,
            keyboardType: inputType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'Nirmala',
                fontSize: 17,
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}