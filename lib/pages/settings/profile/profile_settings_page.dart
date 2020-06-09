import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:treeapp/pages/settings/profile/profile_settings_bloc.dart';
import 'package:treeapp/pages/settings/profile/profile_settings_state.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/widgets/curved_scaffold.dart';

class ProfileSettingsPage extends StatefulWidget {

  final int index;
  final ProfileSettingsBloc Function() initProfileSettingsBloc;

  const ProfileSettingsPage({
    Key key,
    this.index,
    this.initProfileSettingsBloc
  }) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>{

  ProfileSettingsBloc _profileSettingsBloc;

  @override
  void initState() {
    _profileSettingsBloc = widget.initProfileSettingsBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children: <Widget>[
        _personal(),
        _church(),
        _phone()
      ],
      index: widget.index,
    );
  }

  _buildAppBar(title) {
    return Padding(
      padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (Platform.isIOS)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = MaskedTextController(mask: "(000) 000-0000");
  TextEditingController pass1 = TextEditingController();
  String countryCode = "+1";

  _personal(){
    return CurvedScaffold(
      curveRadius: 25,
      appBar: _buildAppBar("Update Personal Information"),
      body: Container(
        height: double.maxFinite,
        child: StreamBuilder(
          stream: _profileSettingsBloc.settingState$,
          initialData: _profileSettingsBloc.settingState$.value,
          builder: (context, data){
            ProfileSettingsState state = data.data;
            firstName.text = state.firstName;
            lastName.text = state.lastName;

            if(state.isChurch){
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "CONTACT FIRST NAME",
                            style: TextStyle(
                                fontFamily: 'NirmalaB',
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                color: Colors.black38
                            )
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Icon(
                                Icons.person,
                                size: 23,
                                color: Colors.black45,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Flexible(
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter Contact First Name",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Nirmala',
                                      fontSize: 17.0,
                                      color: Colors.black26,
                                      fontWeight: FontWeight.normal,
                                    )
                                ),
                                style: TextStyle(
                                  fontFamily: 'Nirmala',
                                  fontSize: 20.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                                cursorColor: Colors.black,
                                cursorWidth: 1,
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                controller: firstName,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 1.0,
                          width: double.infinity,
                          color: Colors.black12,
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "CONTACT LAST NAME",
                            style: TextStyle(
                                fontFamily: 'NirmalaB',
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                color: Colors.black38
                            )
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Icon(
                                Icons.person,
                                size: 23,
                                color: Colors.black45,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Flexible(
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter Contact Last Name",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Nirmala',
                                      fontSize: 17.0,
                                      color: Colors.black26,
                                      fontWeight: FontWeight.normal,
                                    )
                                ),
                                style: TextStyle(
                                  fontFamily: 'Nirmala',
                                  fontSize: 20.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                                cursorColor: Colors.black,
                                cursorWidth: 1,
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                controller: lastName,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 1.0,
                          width: double.infinity,
                          color: Colors.black12,
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: (){
                          //TODO: Save Personal
                        },
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(
                          "Save",
                          style: TextStyle(
                              fontFamily: 'NirmalaB',
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              color: Colors.white
                          ),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                    SizedBox(height: 50.0),
                  ],
                ),
              );
            }else {
              //TODO: Regular Users
              return Container();
            }
          },
        )
      )
    );
  }

  _church(){
    return CurvedScaffold(
      curveRadius: 25,
      appBar: _buildAppBar("Update Church Information"),
      body: Container(
        height: double.maxFinite,
        child: StreamBuilder(
          stream: _profileSettingsBloc.settingState$,
          initialData: _profileSettingsBloc.settingState$.value,
          builder: (context, data){
            ProfileSettingsState state = data.data;
            int ministryType = state.type;

            if(state.isChurch){
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "Ministry",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                              fontFamily: 'Nirmala',
                              fontWeight: FontWeight.normal,
                            )
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        FlatButton(
                            onPressed: (){
                              print('click2985y28745y');
                            },
                            color: Colors.black.withOpacity(0.06),
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    church_icon,
                                    height: 18,
                                    width: 18,
                                    color: Colors.black38,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),

                                  Text(
                                      ministryType == 0 ? "Adult Ministry" : "Youth Ministry",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'Nirmala',
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      )
                                  ),
                                ],
                              ),
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: (){
                          //TODO: Save Church
                        },
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontFamily: 'NirmalaB',
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                            color: Colors.white
                          ),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                    SizedBox(height: 50.0)
                  ],
                ),
              );
            }else{
              //TODO: Regular Users
              return Container();
            }
          },
        ),
      ),
    );
  }

  _phone(){
    return CurvedScaffold(
      curveRadius: 25,
      appBar: _buildAppBar("Update Phone Information"),
      body: Container(
        height: double.maxFinite,
        child: StreamBuilder(
          stream: _profileSettingsBloc.settingState$,
          initialData: _profileSettingsBloc.settingState$.value,
          builder: (context, data){
            ProfileSettingsState state = data.data;

            if(state.isChurch){
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Enter your mobile number",
                        style: TextStyle(
                          fontFamily: 'Nirmala',
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.normal
                        )
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              //TODO: Country code picker
                            },
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.1),
                                borderRadius: BorderRadius.circular(25)
                              ),
                              child: Center(
                                child: Text(
                                  countryCode,
                                  style: TextStyle(
                                    fontFamily: 'NirmalaB',
                                    fontSize: 14.0,
                                    color: Colors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  child: new TextField(
                                    textInputAction: TextInputAction.done,
                                    textCapitalization: TextCapitalization.sentences,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "(678) 324-4041",
                                      hintStyle: TextStyle(
                                        fontFamily: 'Nirmala',
                                        fontSize: 20.0,
                                        color: Colors.black.withOpacity(0.2),
                                        fontWeight: FontWeight.normal
                                      )
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Nirmala',
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal
                                    ),
                                    controller: phoneNumber,
                                    cursorColor: Colors.black,
                                    cursorWidth: 1,
                                    maxLines: 1,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 2.0,
                        width: double.infinity,
                        color: Colors.black.withOpacity(.2),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      ),
                      Text(
                        "We'll send you a text verification code.",
                        style: TextStyle(
                          fontFamily: 'NirmalaB',
                          fontSize: 12.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "PASSWORD",
                            style: TextStyle(
                              fontFamily: 'NirmalaB',
                              fontSize: 12.0,
                              color: Colors.black38,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.lock,
                                  size: 23,
                                  color: Colors.black38,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: TextField(
                                  textInputAction: TextInputAction.done,
                                  textCapitalization: TextCapitalization.none,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter Password",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Nirmala',
                                      fontSize: 17.0,
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.normal
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Nirmala',
                                    fontSize: 20.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal
                                  ),
                                  cursorColor: Colors.black,
                                  cursorWidth: 1,
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  controller: pass1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 1.0,
                            width: double.infinity,
                            color: Colors.black.withOpacity(.1),
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          )
                        ],
                      ),
                      SizedBox(height: 40.0),
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: (){
                            //TODO: Save Phone
                          },
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text(
                            "Save",
                            style: TextStyle(
                              fontFamily: 'NirmalaB',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              );
            }else{
              //TODO: Regular Users
              return Container();
            }
          },
        ),
      ),
    );
  }
}