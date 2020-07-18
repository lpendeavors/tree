import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
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
              child: Image.asset(
                splashText
              ),
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
    Future.delayed(
      Duration(milliseconds: 3000), 
      () async {
        var loginState = widget.userBloc.loginState$.value;

        if (loginState is LoggedInUser) {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          Navigator.pushReplacementNamed(context, '/getting_started');
        }
      }
    );
  }
  
}