import 'dart:async';

import '../../app/app.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../dependency_injection.dart';
import './email_login_bloc.dart';
import './phone_login_bloc.dart';
import './login_state.dart';
import '../register/register_bloc.dart';
import '../register/register_page.dart';
import '../forgot_password/forgot_password_bloc.dart';
import '../forgot_password/forgot_password_page.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/curved_scaffold.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
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

  final _phoneNumberFocusNode = FocusNode();
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
      Rx.merge([
        _emailLoginBloc.message$,
        widget.userBloc.loginState$
          .where((state) => state is LoggedInUser)
        .map((_) => const LoginMessageSuccess()),
      ]).listen(_showLoginMessage)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: CurvedScaffold(
        scaffoldKey: new GlobalKey<ScaffoldState>(),
        curveRadius: 25,
        appBar: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            s.login,
            style: TextStyle(
              //fontFamily: TrajanProBold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
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