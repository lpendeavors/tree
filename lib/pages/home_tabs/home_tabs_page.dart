import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:treeapp/data/notification/firestore_notification_repository.dart';
import 'package:treeapp/pages/home_tabs/home_tabs_bloc.dart';
import '../../data/request/firestore_request_repository.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../data/room/firestore_room_repository.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../data/chat/firestore_chat_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../widgets/tab_item.dart';
import '../../generated/l10n.dart';
import '../../util/asset_utils.dart';
import '../feed/feed_bloc.dart';
import '../feed/feed_page.dart';
import '../chat_tabs/chat_tabs_page.dart';
import '../chat/chat_tabs_bloc.dart';
import '../explore/explore_bloc.dart';
import '../explore/explore_tabs_page.dart';
import '../profile/profile_bloc.dart';
import '../profile/profile_page.dart';
import 'home_tabs_state.dart';

class HomeTabsPage extends StatefulWidget {
  final UserBloc userBloc;
  final HomeTabsBloc Function() initHomeTabsBloc;
  final FirestorePostRepository postRepository;
  final FirestoreUserRepository userRepository;
  final FirestoreRoomRepository roomRepository;
  final FirestoreGroupRepository groupRepository;
  final FirestoreChatRepository chatRepository;
  final FirestoreRequestRepository requestRepository;
  final FirestoreNotificationRepository notificationRepository;

  const HomeTabsPage({
    Key key,
    @required this.userBloc,
    @required this.initHomeTabsBloc,
    @required this.postRepository,
    @required this.roomRepository,
    @required this.userRepository,
    @required this.groupRepository,
    @required this.chatRepository,
    @required this.requestRepository,
    @required this.notificationRepository,
  }) : super(key: key);

  @override
  _HomeTabsPageState createState() => _HomeTabsPageState();
}

class _HomeTabsPageState extends State<HomeTabsPage> {
  PageController _controller = PageController();
  int _currentPage = 0;

  GlobalKey _popupMenuKey = GlobalKey();
  HomeTabsBloc _homeTabsBloc;

  bool _hasShownSuspsended = false;

  @override
  void initState() {
    super.initState();
    _homeTabsBloc = widget.initHomeTabsBloc();
    _setupNotifications();
    _setupFbMessaging();
    _hasShownSuspsended = false;
  }

  @override
  void dispose() {
    _homeTabsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.userBloc.loginState$.value;
    if (user is LoggedInUser) {
      _checkSuspended(context);
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          _tabs(),
          _bottomNavigation(),
        ],
      ),
    );
  }

  _tabs() {
    return Padding(
      padding: EdgeInsets.only(bottom: 60),
      child: PageView(
        controller: _controller,
        onPageChanged: (page) => setState(() {
          _currentPage = page;
        }),
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          FeedPage(
            userBloc: widget.userBloc,
            initFeedBloc: () => FeedBloc(
              userBloc: widget.userBloc,
              postRepository: widget.postRepository,
              notificationRepository: widget.notificationRepository,
              userRepository: widget.userRepository,
            ),
          ),
          ExploreTabsPage(
            userBloc: widget.userBloc,
            initExploreBloc: () => ExploreBloc(
              userBloc: widget.userBloc,
              postRepository: widget.postRepository,
              userRepository: widget.userRepository,
              requestRepository: widget.requestRepository,
            ),
          ),
          ChatTabsPage(
            userBloc: widget.userBloc,
            initChatBloc: () => ChatTabsBloc(
              userBloc: widget.userBloc,
              groupRepository: widget.groupRepository,
              chatRepository: widget.chatRepository,
            ),
          ),
          ProfilePage(
            isTab: true,
            userBloc: widget.userBloc,
            initProfileBloc: () => ProfileBloc(
              userBloc: widget.userBloc,
              userRepository: widget.userRepository,
              postRepository: widget.postRepository,
              groupRepository: widget.groupRepository,
              requestRepository: widget.requestRepository,
              userId: (widget.userBloc.loginState$.value as LoggedInUser).uid,
            ),
          ),
        ],
      ),
    );
  }

  _bottomNavigation() {
    return StreamBuilder<HomeTabsState>(
      stream: _homeTabsBloc.homeTabsState$,
      initialData: _homeTabsBloc.homeTabsState$.value,
      builder: (context, snapshot) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 65,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.4),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TreeTabItem(
                          title: S.of(context).home_tab_title,
                          iconImage: whiteAppIcon,
                          onTap: () => _changePage(0),
                          isActive: _currentPage == 0,
                          type: 1,
                          icon: null,
                          hasNew: false,
                        ),
                        TreeTabItem(
                          title: S.of(context).explore_tab_title,
                          icon: Icons.search,
                          onTap: () => _changePage(1),
                          isActive: _currentPage == 1,
                          type: 0,
                          iconImage: null,
                          hasNew: snapshot.data != null
                              ? snapshot.data.hasRequests
                              : false,
                        ),
                        Spacer(),
                        TreeTabItem(
                          title: S.of(context).chat_tab_title,
                          icon: Icons.forum,
                          onTap: () => _changePage(2),
                          isActive: _currentPage == 2,
                          type: 1,
                          iconImage: ic_chat,
                          hasNew: snapshot.data != null
                              ? snapshot.data.hasMessages
                              : false,
                        ),
                        TreeTabItem(
                          title: S.of(context).profile_tab_title,
                          icon: Icons.person,
                          onTap: () => _changePage(3),
                          isActive: _currentPage == 3,
                          type: 3,
                          iconImage:
                              widget.userBloc.loginState$.value is LoggedInUser
                                  ? (widget.userBloc.loginState$.value
                                          as LoggedInUser)
                                      .image
                                  : null,
                          hasNew: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  key: _popupMenuKey,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      _showAddPopupMenu(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 5),
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPopupMenu(BuildContext context) {
    var menu = PopupMenu(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      lineColor: Colors.white.withOpacity(0.5),
      items: [
        MenuItem(
            title: 'Post',
            textStyle: _menuItemTextStyle(),
            image: _menuItemIconImage(post_icon)),
        MenuItem(
          title: 'Poll',
          textStyle: _menuItemTextStyle(),
          image: _menuItemIconImage(poll_icon),
        ),
        MenuItem(
          title: 'Event',
          textStyle: _menuItemTextStyle(),
          image: _menuItemIconImage(event_icon),
        ),
      ],
      onClickMenu: (item) {
        switch (item.menuTitle) {
          case 'Post':
            Navigator.of(context).pushNamed(
              '/edit_post',
              arguments: <String, dynamic>{
                "postId": null,
                "groupId": null,
              },
            );
            break;
          case 'Poll':
            Navigator.of(context).pushNamed(
              '/edit_poll',
              arguments: <String, dynamic>{
                "postId": null,
                "groupId": null,
              },
            );
            break;
          case 'Event':
            Navigator.of(context).pushNamed(
              '/event_types',
            );
            break;
        }
      },
    );

    menu.show(widgetKey: _popupMenuKey);
  }

  TextStyle _menuItemTextStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.white,
    );
  }

  Image _menuItemIconImage(
    String path,
  ) {
    return Image.asset(
      path,
      height: 20,
      width: 20,
      color: Colors.white,
    );
  }

  void _changePage(int page) {
    _controller.jumpToPage(page);
    setState(() {
      _currentPage = page;
    });
  }

  void _checkSuspended(BuildContext context) async {
    var user = widget.userBloc.loginState$.value as LoggedInUser;
    if (user.isSuspended && !_hasShownSuspsended) {
      _hasShownSuspsended = true;
      Future.delayed(Duration.zero, () async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        width: 15,
                      ),
                      Image.asset(
                        ic_launcher,
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 1,
                        child: Text(
                          'Tree',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                ),
                content: Container(
                  height: 100,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'You account has been suspended. Contact support@yourtreeapp.com',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      });
    }
  }

  void _setupNotifications() async {
    var notificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
      print(payload);
    });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {});
  }

  void _setupFbMessaging() async {
    var fbMessaging = FirebaseMessaging();
    fbMessaging.configure(
      onMessage: notificationOnMessage,
      onLaunch: notificationOnLaunch,
      onResume: notificationOnResume,
      onBackgroundMessage: onBackgroundMessage,
    );
    fbMessaging.setAutoInitEnabled(true);
    // fbMessaging.subscribeToTopic('all');
    fbMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    fbMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    Stream<String> fcmStream = fbMessaging.onTokenRefresh;

    fcmStream.listen((token) async {
      if (token != null) {
        widget.userBloc.updateToken(token);
      }
    });

    fbMessaging.getToken().then((String token) async {
      if (token != null) {
        widget.userBloc.updateToken(token);
      }
    });
  }
}

Future onBackgroundMessage(Map<String, dynamic> message) async {
  print("Maugost B ${message}");
  await showNotification(message);
}

Future notificationOnMessage(Map<String, dynamic> message) async {
  print("Maugost M ${message}");
  await showNotification(message);
}

Future notificationOnResume(Map<String, dynamic> message) async {
  print("Maugost R ${message}");
  await showNotification(message);
}

Future notificationOnLaunch(Map<String, dynamic> message) async {
  print("Maugost L ${message}");
  await showNotification(message);
}

showNotification(Map<String, String> notification) async {
  var notificationsPlugin = FlutterLocalNotificationsPlugin();

  var android = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker',
  );

  var ios = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  var platformChannelSpecifics = NotificationDetails(
    android: android,
    iOS: ios,
  );

  await notificationsPlugin.show(
    0,
    notification['title'],
    notification['body'],
    platformChannelSpecifics,
    payload: jsonEncode(notification['payload']),
  );
}
