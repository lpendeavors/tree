import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/bloc/bloc_provider.dart';
import 'package:treeapp/pages/home_tabs/home_tabs_bloc.dart';
import 'package:treeapp/pages/home_tabs/home_tabs_page.dart';
import '../../dependency_injection.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';

class SplashPage extends StatefulWidget {
  final UserBloc userBloc;

  const SplashPage({
    Key key,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _setupAnimation();
    _setupRedirect();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(splashText),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                splashIcon,
                height: 150,
                width: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 800,
      ),
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInCirc,
      ),
    );

    _animationController.forward();
  }

  void _setupRedirect() {
    Future.delayed(Duration(milliseconds: 3000), () async {
      var loginState = widget.userBloc.loginState$.value;

      if (loginState is LoggedInUser) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeTabsPage(
            initHomeTabsBloc: () => HomeTabsBloc(
              userBloc: BlocProvider.of<UserBloc>(context),
              requestRepository: Injector.of(context).requestRepository,
              chatRepository: Injector.of(context).chatRepository,
            ),
            userBloc: BlocProvider.of<UserBloc>(context),
            postRepository: Injector.of(context).postRepository,
            roomRepository: Injector.of(context).roomRepository,
            userRepository: Injector.of(context).userRepository,
            chatRepository: Injector.of(context).chatRepository,
            groupRepository: Injector.of(context).groupRepository,
            requestRepository: Injector.of(context).requestRepository,
            notificationRepository: Injector.of(context).notificationRepository,
          );
        }));
      } else {
        Navigator.pushReplacementNamed(context, '/getting_started');
      }
    });
  }
}
