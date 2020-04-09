import 'package:flutter/material.dart';
import '../../util/asset_utils.dart';
import '../../generated/l10n.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';

class GettingStartedPage extends StatefulWidget {
  final UserBloc userBloc;

  const GettingStartedPage({
    Key key,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _GettingStartedState createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStartedPage> {
  @override
  void initState() {
    super.initState();

    var loginState = widget.userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      Navigator.of(context).pushNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(loginBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Image.asset(
                whiteLogo,
                height: 150,
                width: 150,
                scale: 2.9,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).getting_started_title,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    padding: EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    color: Theme.of(context).primaryColor,
                    child: Center(
                      child: Text(
                        S.of(context).getting_started_button,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: S.of(context).already_have_an_account
                          ),
                          TextSpan(
                            text: S.of(context).login_here,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}