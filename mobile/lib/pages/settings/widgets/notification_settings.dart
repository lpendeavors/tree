import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() => 
    _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 60),
        children: <Widget>[
          _menuItem(
            title: 'Push Notifications',
            subTitle: 'Disabled',
            isActive: false, 
            onClicked: null,
          ),
          _menuItem(
            title: 'Private Chat', 
            subTitle: 'People cannot chat you privately', 
            isActive: false, 
            onClicked: null,
          ),
          _menuItem(
            title: 'Hide Profile', 
            subTitle: 'Your profile is visible to others', 
            isActive: false, 
            onClicked: null
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    @required String title,
    @required String subTitle,
    @required bool isActive,
    @required Function() onClicked,
  }) {
    return InkWell(
      onTap: onClicked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(

                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        subTitle,
                        style: TextStyle(

                        ),
                      ),
                      SizedBox(height: 10),
                      if (isActive) ...[
                        Container(
                          height: 20,
                          width: 20,
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          child: Container(
                            height: 20,
                            width: 20,
                            child: Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!isActive) ...[
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.04),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}