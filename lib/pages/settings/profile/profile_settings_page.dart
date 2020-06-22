import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
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
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    _profileSettingsBloc = widget.initProfileSettingsBloc();

    _subscriptions = [
      _profileSettingsBloc.message$.listen(_showSettingsMessage)
    ];

    super.initState();
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _profileSettingsBloc.dispose();
    super.dispose();
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
  TextEditingController aboutMe = TextEditingController();
  TextEditingController phoneNumber = MaskedTextController(mask: "(000) 000-0000");
  TextEditingController pass1 = TextEditingController();
  String countryCode = "+1";

  List<DropdownMenuItem<String>> statusList = <DropdownMenuItem<String>>[
    DropdownMenuItem(
      child: Text(
        "Single",
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
          fontFamily: 'Nirmala',
          fontWeight: FontWeight.normal
        )
      ),
      value: "Single"
    ),
    DropdownMenuItem(
      child: Text(
        "Dating",
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
          fontFamily: 'Nirmala',
          fontWeight: FontWeight.normal
        )
      ),
      value: "Dating",
    ),
    DropdownMenuItem(
      child: Text(
        "Married",
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
            fontFamily: 'Nirmala',
            fontWeight: FontWeight.normal
          )
      ),
      value: "Married",
    )
  ];

  List<DropdownMenuItem<String>> titleList = <DropdownMenuItem<String>>[
    DropdownMenuItem(
      child: Text(
          "Author",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Author",
    ),
    DropdownMenuItem(
      child: Text(
          "Speaker",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Speaker",
    ),
    DropdownMenuItem(
      child: Text(
          "Blogger",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Blogger",
    ),
    DropdownMenuItem(
      child: Text(
          "Actor",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Actor",
    ),
    DropdownMenuItem(
      child: Text(
          "Actress",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Actress",
    ),
    DropdownMenuItem(
      child: Text(
          "Comedian",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Comedian",
    ),
    DropdownMenuItem(
      child: Text(
          "Public Figure",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Public Figure",
    ),
    DropdownMenuItem(
      child: Text(
          "Musician",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Musician",
    ),
    DropdownMenuItem(
      child: Text(
          "Pastor",
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Nirmala',
              fontWeight: FontWeight.normal
          )
      ),
      value: "Pastor",
    )
  ];

  bool isPublic;
  String city;
  String address;
  String relationship;
  String title;

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

            if(state.isLoading){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            firstName.text = state.firstName;
            lastName.text = state.lastName;
            phoneNumber.text = state.phoneNo.substring(state.phoneNo.length - 10);
            aboutMe.text = state.bio;

            _profileSettingsBloc.setFirstName(state.firstName);
            _profileSettingsBloc.setLastName(state.lastName);
            _profileSettingsBloc.setPhoneNumber(state.phoneNo);
            _profileSettingsBloc.setBio(state.bio);
            _profileSettingsBloc.setRelationship(relationship ?? state.relationship);
            _profileSettingsBloc.setTitle(title ?? state.title);
            _profileSettingsBloc.setCity(city ?? state.city);
            _profileSettingsBloc.setAddress(address ?? state.address);

            if(isPublic == null){
              isPublic = state.isPublic;
            }

            if(city == null){
              city = state.city;
            }

            if(address == null){
              address = state.address;
            }

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
                                onChanged: _profileSettingsBloc.setFirstName,
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
                                onChanged: _profileSettingsBloc.setLastName,
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
                          _profileSettingsBloc.saveChanges();
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
            } else {
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
                            "FIRST NAME",
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
                                onChanged: _profileSettingsBloc.setFirstName,
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
                            "LAST NAME",
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
                                onChanged: _profileSettingsBloc.setLastName,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              dating_icon,
                              height: 20,
                              width: 20,
                              color: Colors.black.withOpacity(.4),
                            ),
                            SizedBox(width: 10.0),
                            Flexible(
                              child: DropdownButton(
                                value: relationship ?? state.relationship,
                                isExpanded: true,
                                style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Nirmala', fontWeight: FontWeight.normal),
                                items: statusList,
                                onChanged: (s){
                                  print(s);
                                  _profileSettingsBloc.setRelationship(s);
                                  setState(() {
                                    relationship = s;
                                  });
                                },
                                hint: Text(
                                  "Select your relationship status",
                                  style: TextStyle(fontSize: 17.0, color: Colors.black.withOpacity(.2), fontFamily: 'Nirmala', fontWeight: FontWeight.normal),
                                ),
                                underline: Container(),
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "CITY",
                            style: TextStyle(fontSize: 12.0, color: Colors.black.withOpacity(.4), fontFamily: 'Nirmala', fontWeight: FontWeight.normal)
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.home,
                              size: 25,
                              color: Colors.black.withOpacity(.4),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: InkWell(
                                onTap: () async {
                                  LocationResult result = await showLocationPicker(
                                      context,
                                      'AIzaSyBJp2E8-Vsc6x9MFkQqD2_oGBskyVfV8xQ'
                                  );
                                  var cityString = '${result.toString().split(", ")[1]}, ${result.toString().split(", ")[2]}';

                                  _profileSettingsBloc.setCity(cityString);
                                  setState(() {
                                    city = cityString;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Text(
                                            city.isEmpty ? "Where do you live?" : city,
                                            style: TextStyle(fontSize: 17.0, color: Colors.black.withOpacity(city.isEmpty ? (.2) : 1), fontFamily: 'Nirmala', fontWeight: FontWeight.normal)
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.search,
                              size: 25,
                              color: Colors.black.withOpacity(.4),
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
                    SizedBox(height: 10.0),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 25,
                              width: 25,
                              padding: EdgeInsets.all(5),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPublic ? Theme.of(context).primaryColor : Colors.transparent,
                                    border: Border.all(color: isPublic ? Theme.of(context).primaryColor : Colors.transparent)
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(width: 2, color: isPublic ? Theme.of(context).primaryColor : Colors.grey)
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Flexible(
                              child: InkWell(
                                onTap: (){
                                  _profileSettingsBloc.setIsPublic(!isPublic);
                                  setState(() {
                                    isPublic = !isPublic;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Text(
                                          "Request profile to be a public figure",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black.withOpacity(isPublic ? 1 : .2)),
                                        ),
                                      ),
                                      SizedBox(width: 10.0)
                                    ],
                                  ),
                                ),
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
                    AnimatedContainer(
                      duration: Duration(milliseconds: 5),
                      child: isPublic ? Column(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.black.withOpacity(.4),
                                  ),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: DropdownButton(
                                      value: title ?? state.title,
                                      isExpanded: true,
                                      style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Nirmala', fontWeight: FontWeight.normal),
                                      items: titleList,
                                      onChanged: (s){
                                        _profileSettingsBloc.setTitle(s);
                                        setState(() {
                                          title = s;
                                        });
                                      },
                                      hint: Text(
                                        "How may we address you?",
                                        style: TextStyle(fontSize: 17.0, color: Colors.black.withOpacity(.2), fontFamily: 'Nirmala', fontWeight: FontWeight.normal)
                                      ),
                                      underline: Container(),
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
                          SizedBox(height: 10.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "ADDRESS",
                                style: TextStyle(fontSize: 12.0, color: Colors.black.withOpacity(.4), fontFamily: 'Nirmala', fontWeight: FontWeight.normal),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.business,
                                    size: 25,
                                    color: Colors.black.withOpacity(.4),
                                  ),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: InkWell(
                                      onTap: () async {
                                        LocationResult result = await showLocationPicker(
                                            context,
                                            'AIzaSyBJp2E8-Vsc6x9MFkQqD2_oGBskyVfV8xQ'
                                        );

                                        _profileSettingsBloc.setAddress(result.address);
                                        setState(() {
                                          address = result.address;
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        width: double.infinity,
                                        child: Row(
                                          children: <Widget>[
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: Text(
                                                  address.isEmpty ? "Enter your business address" : address,
                                                  style: TextStyle(fontSize: 17.0, color: Colors.black.withOpacity(address.isEmpty ? (.2) : 1), fontFamily: 'Nirmala', fontWeight: FontWeight.normal)
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Icon(
                                    Icons.search,
                                    size: 25,
                                    color: Colors.black.withOpacity(.4),
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
                          )
                        ],
                      ) : null,
                      curve: Curves.easeOut,
                    ),
                    SizedBox(height: 15.0),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "BIO",
                          style: TextStyle(fontSize: 12.0, color: Colors.black.withOpacity(.4), fontFamily: 'NirmalaB', fontWeight: FontWeight.bold)
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Icon(
                                Icons.edit,
                                size: 23,
                                color: Colors.black.withOpacity(.4),
                              ),
                            ),
                            SizedBox(width: 15.0),
                            Flexible(
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Describe yourself (Optional)",
                                    hintStyle: TextStyle(fontSize: 17.0, color: Colors.black.withOpacity(.2), fontFamily: 'Nirmala', fontWeight: FontWeight.normal)
                                ),
                                style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Nirmala', fontWeight: FontWeight.normal),
                                cursorColor: Colors.black,
                                cursorWidth: 1,
                                maxLines: 3,
                                controller: aboutMe,
                                onChanged: _profileSettingsBloc.setBio,
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
                    SizedBox(height: 10.0),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: (){
                          _profileSettingsBloc.saveChanges();
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
                                  child: TextField(
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

  void _showSnackBar(message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  _showSettingsMessage(ProfileSettingsMessage message){
    if (message is SettingsMessageSuccess) {
      _showSnackBar("Changes saved!");
    }
  }
}