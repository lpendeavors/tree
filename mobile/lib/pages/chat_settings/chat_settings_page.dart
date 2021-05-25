import 'dart:async';

import 'package:flutter/material.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
import './chat_settings_bloc.dart';
import './chat_settings_state.dart';

class ChatSettingsPage extends StatefulWidget {
  final UserBloc userBloc;
  final ChatSettingsBloc Function() initChatSettingsBloc;

  const ChatSettingsPage({
    Key key,
    @required this.userBloc,
    @required this.initChatSettingsBloc,
  }) : super(key: key);

  @override
  _ChatSettingsPageState createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  ChatSettingsBloc _chatSettingsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _chatSettingsBloc = widget.initChatSettingsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _chatSettingsBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(ChatSettingsMessage message) {
    print('[DEBUG] ChatSettingsMessage=$message');
  }

  @override
  void dispose() {
    print('[DEBUG] _ChatSettingsState#dispose');
    _subscriptions.forEach((s) => s.cancel());
    _chatSettingsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatSettingsState>(
      stream: _chatSettingsBloc.chatSettingsState$,
      initialData: _chatSettingsBloc.chatSettingsState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        if (data.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        _setControllerValues(data.chatSettings);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Chat Settings',
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
           body: Scrollbar(
             child: ListView(
               physics: ClampingScrollPhysics(),
               padding: EdgeInsets.only(bottom: 60),
               children: <Widget>[
                 _chatSettingsToggle(
                   title: 'Message Notifications',
                   subtitle: '${(data.chatSettings.messageNotifications) ? 'Unmute' : 'Mute'} all message notifications',
                   setting: data.chatSettings.messageNotifications,
                   onToggle: (setting) {
                     _chatSettingsBloc.messageNotificationsChanged(setting);
                     _chatSettingsBloc.saveSettings();
                   },
                 ),
                 _chatSettingsToggle(
                   title: 'Chat Notifications',
                   subtitle: '${(data.chatSettings.chatNotifications) ? 'Unmute' : 'Mute'} all chat notifications',
                   setting: data.chatSettings.chatNotifications,
                   onToggle: (setting) { 
                     _chatSettingsBloc.chatNotificationsChanged(setting);
                     _chatSettingsBloc.saveSettings();
                   },
                 ),
                 _chatSettingsToggle(
                   title: 'Group Notifications',
                   subtitle: '${(data.chatSettings.groupNotifications) ? 'Unmute' : 'Mute'} all group notifications',
                   setting: data.chatSettings.groupNotifications,
                   onToggle: (setting) { 
                      _chatSettingsBloc.groupNotificationsChanged(setting);
                      _chatSettingsBloc.saveSettings();
                   },
                 ),
                 _chatSettingsToggle(
                   title: 'Online Status',
                   subtitle: '${(data.chatSettings.onlineStatus) ? 'Show' : 'Dont show'} my connections I am online',
                   setting: data.chatSettings.onlineStatus,
                   onToggle: (setting) { 
                      _chatSettingsBloc.onlineStatusChanged(setting);
                      _chatSettingsBloc.saveSettings();
                   },
                 ),
               ],
             ),
           ),
        );
      },
    );
  }

  Widget _chatSettingsToggle({
    @required String title,
    @required String subtitle,
    @required bool setting,
    @required Function(bool) onToggle,
  }) {
    return Column(
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
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: setting,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.black.withOpacity(0.04),
        ),
      ],
    );
  }

  void _setControllerValues(ChatSettingsItem settings) {
    _chatSettingsBloc.messageNotificationsChanged(settings.messageNotifications);
    _chatSettingsBloc.groupNotificationsChanged(settings.groupNotifications);
    _chatSettingsBloc.chatNotificationsChanged(settings.chatNotifications);
    _chatSettingsBloc.onlineStatusChanged(settings.onlineStatus);
  }
}