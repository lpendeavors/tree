import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/country.dart';
import '../../pages/login/login_state.dart';
import '../../pages/login/phone_login_bloc.dart';
import '../../pages/register/register_state.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/curved_scaffold.dart';
import '../../widgets/input_field.dart';
import '../../widgets/modals/country_code_modal.dart';
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
  PhoneLoginBloc _phoneLoginBloc;
  List<StreamSubscription> _subscriptions;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isChurch = false;

  @override
  void initState() {
    super.initState();

    _registerBloc = RegisterBloc(widget.userRepository);
    _phoneLoginBloc = PhoneLoginBloc(widget.userRepository);
    _subscriptions = [
      _phoneLoginBloc.message$.listen(_showRegisterMessage)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    String _phone;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: CurvedScaffold(
        curveRadius: 25,
        appBar: TreeAppBar(
          title: s.sign_up,
          backButton: true,
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CountryCodeModal();
                        },
                      ).then((country) {
                        if (country != null) {
                          var selectedCountry = country as Country;
                          _phoneLoginBloc.countryCodeChanged(selectedCountry.phoneCode);
                        }
                      });
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
                      child: TreeInputField(
                        autofocus: true,
                        inputType: TextInputType.phone,
                        inputAction: TextInputAction.done,
                        hintText: s.phone_number_hint,
                        onChange: _phoneLoginBloc.phoneNumberChanged,
                        hasMask: true,
                        mask: s.phone_number_mask,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 2,
                width: double.infinity,
                color: Colors.black.withOpacity(0.2),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Text(
                s.verification_hint,
                style: TextStyle(
                  fontFamily: 'NirmalaB',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 40),
              Container(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: _phoneLoginBloc.submitLogin,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    s.sign_up_continue,
                    style: TextStyle(
                      fontFamily: 'NirmalaB',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: Text(
                  s.or,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  color: _isChurch ? Colors.blue : Color(0XFFe46514),
                  textColor: Colors.white,
                  child: Text(
                    s.sign_up_as(_isChurch ? s.person : s.church),
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'NirmalaB',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)
                  ),
                  onPressed: () {
                    setState(() {
                      _isChurch = !_isChurch;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        )
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

  void _showSnackBar(message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  _showRegisterMessage(LoginMessage message) async {
    final s = S.of(context);
    if (message is LoginPhoneSuccess) {
      _showSnackBar(s.phone_login_success);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushNamed(
        '/phone_verification',
        arguments: message.verificationId,
      );
    }
  }
}