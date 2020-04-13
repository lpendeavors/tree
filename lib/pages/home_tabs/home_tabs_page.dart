import 'package:flutter/material.dart';
import '../../data/post/firestore_post_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../widgets/tab_item.dart';
import '../../generated/l10n.dart';
import '../feed/feed_bloc.dart';
import '../feed/feed_page.dart';

class HomeTabsPage extends StatefulWidget {
  final UserBloc userBloc;

  final FirestorePostRepository postRepository;

  const HomeTabsPage({
    Key key,
    this.userBloc,
    this.postRepository,
  }) : super(key: key);

  @override
  _HomeTabsPageState createState() => _HomeTabsPageState();
}

class _HomeTabsPageState extends State<HomeTabsPage> {
  PageController _controller = PageController();
  int _currentPage = 0;

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
        onPageChanged: (page) => setState(() { _currentPage = page; }),
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          FeedPage(
            userBloc: widget.userBloc,
            feedBloc: FeedBloc(
              userBloc: widget.userBloc,
              postRepository: widget.postRepository,
            ),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.blue,
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.purple,
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  _bottomNavigation() {
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
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TreeTabItem(
                      title: S.of(context).home_tab_title,
                      icon: Icons.home,
                      onTap: () => _changePage(0),
                      isActive: _currentPage == 0,
                    ),
                    TreeTabItem(
                      title: S.of(context).explore_tab_title,
                      icon: Icons.search,
                      onTap: () => _changePage(1),
                      isActive: _currentPage == 1,
                    ),
                    Spacer(),
                    TreeTabItem(
                      title: S.of(context).chat_tab_title,
                      icon: Icons.forum,
                      onTap: () => _changePage(2),
                      isActive: _currentPage == 2,
                    ),
                    TreeTabItem(
                      title: S.of(context).profile_tab_title,
                      icon: Icons.person,
                      onTap: () => _changePage(3),
                      isActive: _currentPage == 3,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  _showAddPopupMenu();
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
  }

  void _showAddPopupMenu() {

  }

  void _changePage(int page) {
    _controller.jumpToPage(page);
    setState(() {
      _currentPage = page;
    });
  }
}