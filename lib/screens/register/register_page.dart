import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:treeapp/screens/register/register_state.dart';
import 'package:treeapp/widgets/app_bar.dart';
import 'package:treeapp/widgets/curved_scaffold.dart';
import '../../user_bloc/user_bloc.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../generated/l10n.dart';
import './register_bloc.dart';

class RegisterPage extends StatefulWidget {
  final FirestoreUserRepository userRepository;
  final UserBloc userBloc;

  const RegisterPage({
    Key key,
    @required this.userRepository,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc _registerBloc;
  List<StreamSubscription> _subscriptions;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _registerBloc = RegisterBloc(widget.userRepository);
    _subscriptions = [_registerBloc.message$.listen(_showRegisterMessage)];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: CurvedScaffold(
        curveRadius: 25,
        appBar: TreeAppBar(
          title: s.sign_up,
          backButton: true,
        ),
        body: Container(

        ),
      )
    );
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _registerBloc.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {

  }

  _showRegisterMessage(RegisterMessage message) async {

  }
}