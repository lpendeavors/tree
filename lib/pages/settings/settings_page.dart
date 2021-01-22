import 'package:flutter/material.dart';
import '../../user_bloc/user_login_state.dart';
import '../../widgets/modals/profile_image_modal.dart';
import '../../widgets/modals/sign_out_modal.dart';
import '../../user_bloc/user_bloc.dart';
import './settings_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final UserBloc userBloc;

  const SettingsPage({
    Key key,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: StreamBuilder<Object>(
          stream: widget.userBloc.loginState$,
          initialData: widget.userBloc.loginState$.value,
          builder: (context, snapshot) {
            if (!(snapshot.data is LoggedInUser)) {
              backToLogin(() {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/getting_started', (route) => false);
              });
            }

            return Scrollbar(
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
                    onClicked: (index) => Navigator.of(context)
                        .pushNamed('/update_info', arguments: index),
                    alertBackground: false,
                  ),
                  _menuItem(
                    title: 'App & Settings',
                    listItems: ['Notification Settings'],
                    onClicked: (index) => Navigator.of(context)
                        .pushNamed('/notification_settings'),
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
                      onClicked: (index) =>
                          _showLogoutConfirmation(LogoutType.values[index]),
                      alertBackground: true),
                ],
              ),
            );
          }),
    );
  }

  void backToLogin(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
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
                              color: (alertBackground && index == 0)
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.4),
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
        launch("https://www.yourtreeapp.com/privacy");
        break;
      case PolicyType.termsOfService:
        launch("https://www.yourtreeapp.com/Terms%20of%20Use2/");
        break;
      default:
        break;
    }
  }

  void _showLogoutConfirmation(LogoutType type) {
    switch (type) {
      case LogoutType.logOut:
        showDialog(
            context: context,
            builder: (context) {
              return LogoutModal();
            }).then((value) {
          if (value) {
            widget.userBloc.signOut.add(null);
          }
        });
        break;
      default:
        break;
    }
  }
}
