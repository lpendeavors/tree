import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';
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

  @override
  void initState() {
    super.initState();
    _homeTabsBloc = widget.initHomeTabsBloc();
  }

  @override
  void dispose() {
    _homeTabsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            feedBloc: FeedBloc(
              userBloc: widget.userBloc,
              postRepository: widget.postRepository,
              notificationRepository: widget.notificationRepository,
              userRepository: widget.userRepository,
            ),
          ),
          ExploreTabsPage(
            userBloc: widget.userBloc,
            exploreBloc: ExploreBloc(
              userBloc: widget.userBloc,
              postRepository: widget.postRepository,
              userRepository: widget.userRepository,
              requestRepository: widget.requestRepository,
            ),
          ),
          ChatTabsPage(
            userBloc: widget.userBloc,
            chatBloc: ChatTabsBloc(
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
                arguments: null,
              );
              break;
            case 'Poll':
              Navigator.of(context).pushNamed(
                '/edit_poll',
                arguments: null,
              );
              break;
            case 'Event':
              Navigator.of(context).pushNamed(
                '/event_types',
              );
              break;
          }
        });

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
}
