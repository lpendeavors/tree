import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class TreeInputField extends StatelessWidget {
  final TextInputType inputType;
  final TextInputAction inputAction;
  final IconData icon;
  final bool obscure;
  final bool hasIcon;
  final bool autofocus;
  final String hintText;
  final Function(String) onChange;
  final bool hasMask;
  final String mask;
  final FocusNode selfFocusNode;
  final FocusNode nextFocusNode;

  TreeInputField({
    Key key,
    @required this.inputType,
    @required this.inputAction,
    @required this.hintText,
    @required this.onChange,
    this.autofocus = false,
    this.obscure = false,
    this.hasIcon = false,
    this.hasMask = false,
    this.mask,
    this.icon,
    this.selfFocusNode,
    this.nextFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            obscureText: obscure,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'Nirmala',
                fontSize: 17,
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            onChanged: onChange,
            onSubmitted: (_) {
              selfFocusNode.unfocus();
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              }
            },
            controller: hasMask ? new MaskedTextController(mask: mask) : null,
            focusNode: selfFocusNode != null ? selfFocusNode : null,
          ),
        ),
      ],
    );
  }
}