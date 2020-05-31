import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {

  const NotificationSettingsPage({
    Key key,
  }) : super(key: key);

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>{
  bool pushNotifications = true;
  bool privateChat = true;
  bool publicEmail = true;
  bool publicNumber = true;
  bool hideProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification Settings")),
      body: Scrollbar(
        child: ListView(
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 60),
          children: <Widget>[
            _menuItemV(
                "Push Notifications",
                pushNotifications ? "Enabled" : "Disabled",
                pushNotifications, () {
              setState(() {
                pushNotifications = !pushNotifications;
              });
            }),
            _menuItemV(
                "Private Chat",
                privateChat
                    ? "People can chat you privately"
                    : "People cannot chat you privately",
                privateChat, () {
              setState(() {
                privateChat = !privateChat;
              });
            }),
            _menuItemV(
                "Public Email",
                publicEmail
                    ? "Your email is visible to everyone"
                    : "Your email is not visible to everyone",
                publicEmail, () {
              setState(() {
                publicEmail = !publicEmail;
              });
            }),
            _menuItemV(
                "Public Number",
                publicNumber
                    ? "Your phone number is visible to everyone"
                    : "Your phone number is not visible to everyone",
                publicNumber, () {
              setState(() {
                publicNumber = !publicNumber;
              });
            }),
            _menuItemV(
                "Hide Profile",
                hideProfile
                    ? "Your profile is not shown to peoples pages"
                    : "Your profile is showing to peoples pages",
                hideProfile, () {
              setState(() {
                hideProfile = !hideProfile;
              });
            }),
          ],
        ),
      )
    );
  }

  _menuItemV(title, subTitle, active, onClicked) {
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
                          fontSize: 16.0,
                          color: Colors.black,
                          fontFamily: 'Nirmala'
                        )
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontFamily: 'Nirmala'
                        )
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
                if (active)
                  Container(
                    height: 20,
                    width: 20,
                    padding: EdgeInsets.all(2),
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
                          border:
                          Border.all(color: Colors.black.withOpacity(.4))),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.black.withOpacity(.4))),
                  )
                else
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.black.withOpacity(.4))),
                  )
              ],
            ),
          ),
          Container(
            height: 1.0,
            width: double.infinity,
            color: Colors.black12,
          )
        ],
      ),
    );
  }
}