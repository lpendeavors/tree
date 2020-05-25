import 'dart:async';

import '../../data/user/firestore_user_repository.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import '../../widgets/input_label.dart';
import '../../widgets/input_field.dart';
import './forgot_password_bloc.dart';
import './forgot_password_state.dart';
import 'package:flutter/material.dart';
import '../../widgets/curved_scaffold.dart';
import '../../widgets/app_bar.dart';

class ForgotPasswordPage extends StatefulWidget {
  final FirestoreUserRepository userRepository;
  final UserBloc userBloc;

  const ForgotPasswordPage({
    Key key,
    @required this.userRepository,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ForgotPasswordBloc _forgotPasswordBloc;

  List<StreamSubscription> _subscriptions;
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _forgotPasswordBloc = ForgotPasswordBloc(widget.userRepository);

    _subscriptions = [
      _forgotPasswordBloc.message$.listen(_showResetMessage)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return CurvedScaffold(
      curveRadius: 25,
      appBar: TreeAppBar(
        title: s.login,
        backButton: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            TreeInputLabel(text: s.email_address),
            TreeInputField(
              inputType: TextInputType.emailAddress,
              inputAction: TextInputAction.next,
              autofocus: true,
              hintText: s.email_hint,
              hasIcon: true,
              icon: Icons.email,
              selfFocusNode: _emailFocusNode,
              onChange: _forgotPasswordBloc.emailChanged,
            ),
            Container(
              height: 2.0,
              width: double.infinity,
              color: Colors.black.withOpacity(0.2),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Text(
              s.password_reset_tip, 
              style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
              fontFamily: 'NirmalaB'
            )),
            SizedBox(height: 40),
            Container(
              height: 50,
              width: double.infinity,
              child: RaisedButton(
                onPressed: _forgotPasswordBloc.submit,
                color: Theme.of(context).primaryColor,
                child: Text(
                  s.password_reset_confirm,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'NirmalaB',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _forgotPasswordBloc.dispose();
    super.dispose();
  }

  void _showSnackBar(message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResetMessage(Object message) async {
    final s = S.of(context);
    if (message is InvalidEmailAddress) {
      _showSnackBar(s.invalid_email_error);
    }
    if (message is SendPasswordResetEmailSuccess) {
      _showSnackBar(s.password_reset_success);
      Navigator.popUntil(context, ModalRoute.withName('/login'));
    }
  }
}