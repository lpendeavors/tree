import 'package:flutter/material.dart';
import './settings_state.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Scrollbar(
        child: ListView(
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 60),
          children: <Widget>[
            _menuItem(
              title: 'Profile Settings', 
              listItems: [
                'Update Personal Information',
                'Update Church Information',
                'Update Phone Number',
              ],
              onClicked: (index) => 
                Navigator.of(context).pushNamed('/update_info', arguments: index),
              alertBackground: false,
            ),
            _menuItem(
              title: 'App & Settings',
              listItems: [
                'Notification Settings'
              ],
              onClicked: (index) => 
                Navigator.of(context).pushNamed('/notification_settings'),
              alertBackground: false,
            ),
            _menuItem(
              title: 'App Usage',
              listItems: [
                'Privacy Policy',
                'Terms and Conditions',
              ],
              onClicked: (index) => 
                _showAppPolicy(PolicyType.values[index]),
              alertBackground: false,
            ),
            _menuItem(
              title: 'Account', 
              listItems: [
                'Deactivate Account',
                'Logout',
              ], 
              onClicked: (index) => _showLogoutConfirmation,
              alertBackground: true
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    @required String title,
    @required List<String> listItems,
    @required Function(int) onClicked,
    @required bool alertBackground,
  }) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 60,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 15),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black.withOpacity(0.04),
          ),
          ...List.generate(
            listItems.length, 
            (index) {
              return InkWell(
                onTap: () => onClicked(index),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: (alertBackground && index == 0)
                          ? Colors.red
                          : Colors.white,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              listItems[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: (alertBackground && index == 0)
                                  ? Colors.white
                                  : Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.04),
                        margin: EdgeInsets.all(0),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAppPolicy(PolicyType type) {
    switch (type) {
      case PolicyType.privacyPolicy:
        Navigator.pushNamed(context, '/privacy_policy');
        break;
      case PolicyType.termsOfService:
        Navigator.pushNamed(context, '/terms_of_service');
        break;
      default:
        break;
    }
  }

  void _showLogoutConfirmation(LogoutType type) {
    switch (type) {
      default:
        break;
    }
  }
}