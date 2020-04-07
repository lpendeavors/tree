import 'package:flutter/material.dart';
import '../util/asset_utils.dart';

class TreeAppBar extends StatelessWidget {
  final String title;
  final bool backButton;

  const TreeAppBar({
    @required this.title,
    this.backButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontFamily: TrajanProBold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                ],
              ),
            ],
          ),
          if (backButton) ...[
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }
}