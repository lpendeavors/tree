import '../../widgets/app_bar.dart';
import '../../widgets/curved_scaffold.dart';
import '../login/phone_login_bloc.dart';
import '../../generated/l10n.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/material.dart';

class PhoneVerificationPage extends StatelessWidget {
  final PhoneLoginBloc phoneLoginBloc;

  const PhoneVerificationPage({
    Key key,
    @required this.phoneLoginBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);

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
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              s.verification,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "NirmalaB",
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              width: 170,
              child: TextField(
                textInputAction: TextInputAction.done,
                autofocus: true,
                controller: new MaskedTextController(mask: '000000'),
                textAlign: TextAlign.center,
                cursorColor: Colors.black.withOpacity(0.5),
                cursorWidth: 2,
                maxLines: 1,
                keyboardType: TextInputType.phone,
                onChanged: phoneLoginBloc.verificationCodeChanged,
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Nirmala',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "- - - - - -",
                  hintStyle: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Nirmala',
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Container(
              width: 130,
              height: 2,
              color: Colors.black,
            ),
            SizedBox(height: 10),
            Text(
              s.verification_message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'NirmalaB',
                fontSize: 12,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 35,
              width: 105,
              child: FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      s.verification_resend,
                      style: TextStyle(
                        fontFamily: 'NirmalaB',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(
                    color: Colors.black.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                onPressed: () {
                  // Resend verification code
                },
              ),
            ),
            SizedBox(height: 40),
            Container(
              height: 50,
              width: double.infinity,
              child: RaisedButton(
                onPressed: phoneLoginBloc.submitLogin,
                color: Colors.black.withOpacity(0.7),
                textColor: Colors.white,
                child: Text(
                  s.verify,
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
}