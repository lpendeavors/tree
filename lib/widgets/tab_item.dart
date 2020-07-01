import 'package:flutter/material.dart';

class TreeTabItem extends StatelessWidget {
  final IconData icon;
  final String iconImage;
  final String title;
  final Function() onTap;
  final bool isActive;
  final int type;

  const TreeTabItem({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.onTap,
    @required this.isActive,
    @required this.type,
    @required this.iconImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  type == 0
                    ? Icon(
                        icon,
                        size: isActive ? 22 : 18,
                        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                      )
                    : Image.asset(
                        iconImage,
                        height: isActive ? 22 : 18,
                      ),
                  SizedBox(height: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isActive ? 10 : 12,
                      color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  )
                ],
              ),
            ),
            // Show badge notification
          ],
        ),
      ),
    );
  }
}