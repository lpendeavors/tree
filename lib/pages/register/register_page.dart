import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../pages/phone_verification/phone_verification_state.dart';
import '../../models/country.dart';
import '../../pages/register/register_state.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/curved_scaffold.dart';
import '../../widgets/input_field.dart';
import '../../widgets/modals/country_code_modal.dart';
import '../../user_bloc/user_bloc.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../generated/l10n.dart';
import './phone_register_bloc.dart';

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
  PhoneRegisterBloc _registerBloc;
  List<StreamSubscription> _subscriptions;

  bool _isChurch = false;
  int _step = 0;
  PageController _controller = PageController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if(_step != _controller.page.round().toInt()) {
        setState(() {
          _step = _controller.page.round().toInt();
        });
      }
    });

    _registerBloc = PhoneRegisterBloc(widget.userRepository);
    _subscriptions = [
      _registerBloc.message$.listen(_showRegisterMessage),
      _registerBloc.saveResult$.listen(_showRegisterMessage)
    ];
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
          steps: 2,
          step: _step,
          backButton: true,
        ),
        body: Stack(
          children: <Widget>[
            PageView.builder(
              itemCount: 2,
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              itemBuilder: (context, index){
                return index == 0 ? _firstPage() : _secondPage();
              }
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: _isChurch ? Color(0XFFe46514) : Colors.blue,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (_isChurch)
                        Image.asset(
                          "assets/images/church_icon.png",
                          height: 15,
                          width: 15,
                          color: Colors.white,
                        ),
                      if (!_isChurch)
                        Icon(
                          Icons.person,
                          size: 15,
                          color: Colors.white,
                        ),
                      SizedBox(width: 5.0),
                      Text(
                        _isChurch ? "Church" : "Personal",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            )
          ],
        )
      )
    );
  }

  Widget _firstPage() {
    final s = S.of(context);

    return Container(
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
                      _registerBloc.countryCodeChanged(selectedCountry.phoneCode);
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
              SizedBox(width: 10),
              Flexible(
                child: Container(
                  height: 50,
                  child: TreeInputField(
                    autofocus: true,
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.done,
                    hintText: s.phone_number_hint,
                    onChange: _registerBloc.phoneNumberChanged,
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
              onPressed: _registerBloc.submitRegister,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                s.sign_up_continue,
                style: TextStyle(
                  fontFamily: 'NirmalaB',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
    );
  }

  Widget _secondPage() {
    final s = S.of(context);

    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'EMAIL ADDRESS',
                  style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontFamily: "NirmalaB", fontSize: 12.0)
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.email,
                        size: 23,
                        color: Colors.black38,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: s.email_hint,
                            hintStyle: TextStyle(color: Colors.black26, fontFamily: "Nirmala", fontSize: 17.0)
                          ),
                          style: TextStyle(color: Colors.black, fontFamily: "Nirmala", fontSize: 20.0),
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: _registerBloc.emailAddressChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 6.0,
                  thickness: 1.0,
                  color: Colors.black26,
                )
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'FIRST NAME',
                      style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontFamily: "NirmalaB", fontSize: 12.0)
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.person,
                        size: 23,
                        color: Colors.black38,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: s.f_name_hint,
                              hintStyle: TextStyle(color: Colors.black26, fontFamily: "Nirmala", fontSize: 17.0)
                          ),
                          style: TextStyle(color: Colors.black, fontFamily: "Nirmala", fontSize: 20.0),
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          keyboardType: TextInputType.text,
                          onChanged: _registerBloc.firstNameChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 6.0,
                  thickness: 1.0,
                  color: Colors.black26,
                )
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'LAST NAME',
                      style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontFamily: "NirmalaB", fontSize: 12.0)
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.person,
                        size: 23,
                        color: Colors.black38,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: s.l_name_hint,
                              hintStyle: TextStyle(color: Colors.black26, fontFamily: "Nirmala", fontSize: 17.0)
                          ),
                          style: TextStyle(color: Colors.black, fontFamily: "Nirmala", fontSize: 20.0),
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          keyboardType: TextInputType.text,
                          onChanged: _registerBloc.lastNameChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 6.0,
                  thickness: 1.0,
                  color: Colors.black26,
                )
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'PASSWORD',
                      style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontFamily: "NirmalaB", fontSize: 12.0)
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.lock,
                        size: 23,
                        color: Colors.black38,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: s.password_hint,
                              hintStyle: TextStyle(color: Colors.black26, fontFamily: "Nirmala", fontSize: 17.0)
                          ),
                          style: TextStyle(color: Colors.black, fontFamily: "Nirmala", fontSize: 20.0),
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          onChanged: _registerBloc.passwordChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 6.0,
                  thickness: 1.0,
                  color: Colors.black26,
                )
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'CONFIRM PASSWORD',
                      style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontFamily: "NirmalaB", fontSize: 12.0)
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.lock,
                        size: 23,
                        color: Colors.black38,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: s.retype_hint,
                              hintStyle: TextStyle(color: Colors.black26, fontFamily: "Nirmala", fontSize: 17.0)
                          ),
                          style: TextStyle(color: Colors.black, fontFamily: "Nirmala", fontSize: 20.0),
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          onChanged: _registerBloc.confirmPasswordChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 6.0,
                  thickness: 1.0,
                  color: Colors.black26,
                )
              ],
            ),
            SizedBox(height: 30.0),
            Container(
              height: 50.0,
              width: double.infinity,
              child: RaisedButton(
                onPressed: (){
                  _registerBloc.submitUser(_isChurch);
                },
                color: Color(0xFF6CA748),
                textColor: Colors.white,
                child: Text(
                  s.create_account,
                  style: TextStyle(fontSize: 22.0, color: Colors.white, fontFamily: 'NirmalaB', fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            )
          ],
        )
      ),
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

  void _returnedFromVerification(Object message){
    print('_returnedFromVerification');
    if(message is PhoneVerificationSuccess){
      _registerBloc.verificationResultChanged(message.result);
      setState(() {
        _controller.jumpToPage(2);
      });
    }
  }

  _showRegisterMessage(RegisterMessage message) async {
    final s = S.of(context);
    if (message is RegisterMessageSuccess) {
      _showSnackBar(s.register_success);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (message is RegisterPhoneSuccess) {
      _showSnackBar(s.phone_register_success);

      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushNamed(
        '/phone_verification',
        arguments: [message.verificationId, false],
      ).then(_returnedFromVerification);
    }
    if (message is RegisterMessageError) {
      final error = message.error;
      print('[DEBUG] error=$error');

      switch(error.runtimeType){
        case InvalidBusinessEmailError:
          _showSnackBar("Enter a valid business email address");
          break;
        default:
          _showSnackBar("Unknown error");
      }
    }
    if (message is RegisterMessageComplete) {
      Navigator.of(context).pushNamed('/');
    }

    print('_showRegisterMessage ${message}');
  }
}

/*
Broken verification back button
Continue button
 */