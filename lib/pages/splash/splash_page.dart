import 'dart:async';

import 'package:flutter/material.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_bloc.dart';

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

  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _setupAnimation();
    _setupRedirect();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscriptions.forEach((s) => s.cancel());
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
              color: Theme.of(context).primaryColor,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(splash),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                insideSplash,
                height: 200,
                width: 200,
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
    var loginState = widget.userBloc.loginState$.value;

    Future.delayed(
      Duration(milliseconds: 1500), 
      () async {
        if (loginState != null) {
          Navigator.pushNamed(context, '/');
        } else {
          Navigator.pushNamed(context, '/getting_started');
        }
      }
    );
  }
  
}