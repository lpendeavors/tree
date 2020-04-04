import 'dart:async';

import '../../app/app.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../dependency_injection.dart';
import './email_login_bloc.dart';
import './phone_login_bloc.dart';
import './login_state.dart';
import '../../widgets/curved_scaffold.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
import '../../util/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class LoginPage extends StatefulWidget {
  final FirebaseUserRepository userRepository;
  final UserBloc userBloc;

  const LoginPage({
    Key key,
    @required this.userRepository,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  EmailLoginBloc _emailLoginBloc;
  PhoneLoginBloc _phoneLoginBloc;
  List<StreamSubscription> _subscriptions;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    var loginState = widget.userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      Navigator.of(context).pushNamed('/');
    }

    _emailLoginBloc = EmailLoginBloc(widget.userRepository);

    _subscriptions = [
//      Rx.merge([
//        _emailLoginBloc.message$,
//        widget.userBloc.loginState$
//          .where((state) => state is LoggedInUser)
//        .map((_) => const LoginMessageSuccess()),
//      ]).listen(_showLoginMessage)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    bool phoneLogin = false;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: CurvedScaffold(
        curveRadius: 25,
        appBar: Padding(
          padding: EdgeInsets.all(25),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    s.login,
                    style: TextStyle(
                      fontFamily: TrajanProBold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                s.enter_phone_number,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Nirmala",
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Show country code dialog
                    },
                    child: Container(
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "+1",
                          style: TextStyle(
                            fontFamily: "NirmalaB",
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: Container(
                      height: 50,
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: s.phone_number_hint,
                          hintStyle: TextStyle(
                            fontFamily: "Nirmala",
                            fontSize: 20,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: "Nirmala",
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        cursorColor: Colors.black,
                        cursorWidth: 1,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 2,
                width: double.infinity,
                color: Colors.black.withOpacity(0.2),
                margin: EdgeInsets.only(bottom: 10),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    s.login_method(phoneLogin ? s.phone : s.email),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  onPressed: phoneLogin
                      ? () {}
                      : _emailLoginBloc.submitLogin,
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    s.login,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'NirmalaB',
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/forgot_password');
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    s.forgot_password,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _emailLoginBloc.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_emailLoginBloc.isLoading$.value) {
      final s = S.of(context);
      final exitSignIn = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(s.exit_login),
            content: Text(s.exit_login_message),
            actions: <Widget>[
              FlatButton(
                child: Text(s.no),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text(s.exit),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        }
      );
      return exitSignIn ?? false;
    }
    return true;
  }

  _showSnackBar(message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoginMessage(LoginMessage message) async {
    final s = S.of(context);
    if (message is LoginMessageSuccess) {
      _showSnackBar(s.login_success);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (message is LoginMessageError) {
      final error = message.error;
      print('[DEBUG] error=$error');
      
      if (error is NetworkError) {
        _showSnackBar(s.network_error);
      }
      if (error is TooManyRequestsError) {
        _showSnackBar(s.too_many_requests_error);
      }
      if (error is UserNotFoundError) {
        _showSnackBar(s.user_not_found_error);
      }
      if (error is WrongPasswordError) {
        _showSnackBar(s.wrong_password_error);
      }
      if (error is InvalidEmailError) {
        _showSnackBar(s.invalid_email_error);
      }
//      if (error is EmailAlreadyInUserError) {
//        _showSnackBar(s.email_already_in_use_error);
//      }
      if (error is WeakPasswordError) {
        _showSnackBar(s.weak_password_error);
      }
//      if (error is UserDisabledError) {
//        _showSnackBar(s.user_disabled_error);
//      }
//      if (error is InvalidCredentialError) {
//        _showSnackBar(s.invalid_credential_error);
//      }
      if (error is UnknownError) {
        _showSnackBar(s.error_occurred);
      }
    }
  }
}