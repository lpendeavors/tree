import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../util/asset_utils.dart';

class TreeAppBar extends StatelessWidget {
  final String title;
  final int step;
  final int steps;
  final bool backButton;

  const TreeAppBar({
    @required this.title,
    this.step = 0,
    this.steps = 0,
    this.backButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                children: List.generate(this.steps, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 5.0, left: 5.0, top: 10.0),
                    child: index == this.step ? CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: 6.0,
                    ) : CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(150),
                      maxRadius: 4.0,
                    ),
                  );
                })
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