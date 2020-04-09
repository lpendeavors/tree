import 'package:flutter/material.dart';

class TreeTabItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function() onTap;
  final bool isActive;

  const TreeTabItem({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.onTap,
    @required this.isActive,
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
                  Icon(
                    icon,
                    size: isActive ? 22 : 18,
                    color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  SizedBox(height: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isActive ? 10 : 12,
                      color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
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