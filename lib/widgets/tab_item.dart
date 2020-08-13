import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/util/asset_utils.dart';

class TreeTabItem extends StatelessWidget {
  final IconData icon;
  final String iconImage;
  final String title;
  final Function() onTap;
  final bool isActive;
  final int type;
  final bool hasNew;

  const TreeTabItem({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.onTap,
    @required this.isActive,
    @required this.type,
    @required this.iconImage,
    @required this.hasNew,
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
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        )
                      : type != 3
                          ? Image.asset(
                              iconImage,
                              height: isActive ? 22 : 18,
                              color: isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            )
                          : Container(
                              height: isActive ? 22 : 18,
                              width: isActive ? 22 : 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withOpacity(0.4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    (isActive ? 22 : 18) / 2),
                                child: iconImage == null
                                    ? Image.asset(appIcon)
                                    : CachedNetworkImage(
                                        imageUrl: iconImage,
                                        height: isActive ? 22 : 18,
                                        width: isActive ? 22 : 18,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                  SizedBox(height: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isActive ? 10 : 12,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  )
                ],
              ),
            ),
            if (hasNew)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 10,
                  width: 10,
                  margin: EdgeInsets.only(right: 15),
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
