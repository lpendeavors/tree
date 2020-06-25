import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/pages/login/email_login_bloc.dart';
import 'package:treeapp/pages/perform_search/perform_search_state.dart';
import 'package:treeapp/widgets/modals/list_dialog.dart';
import '../../../pages/login/login_state.dart';
import '../../../pages/phone_verification/phone_verification_state.dart';
import '../../../models/country.dart';
import '../../../data/user/firestore_user_repository.dart';
import '../../../widgets/modals/country_code_modal.dart';
import '../../../pages/login/phone_login_bloc.dart';
import '../../../pages/settings/profile/profile_settings_bloc.dart';
import '../../../pages/settings/profile/profile_settings_state.dart';
import '../../../util/asset_utils.dart';
import '../../../widgets/curved_scaffold.dart';
import '../../../generated/l10n.dart';

class ProfileSettingsPage extends StatefulWidget {

  final FirestoreUserRepository userRepository;
  final int index;
  final ProfileSettingsBloc Function() initProfileSettingsBloc;

  const ProfileSettingsPage({
    Key key,
    this.index,
    this.initProfileSettingsBloc,
    @required this.userRepository,
  }) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>{

  ProfileSettingsBloc _profileSettingsBloc;
  PhoneLoginBloc _phoneLoginBloc;
  EmailLoginBloc _emailLoginBloc;
  List<StreamSubscription> _subscriptions;

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController aboutMe = TextEditingController();
  TextEditingController phoneNumber = MaskedTextController(mask: "(000) 000-0000");
  TextEditingController pass1 = TextEditingController();
  TextEditingController churchID = TextEditingController();
  TextEditingController churchName = TextEditingController();

  TextEditingController aboutChurch = TextEditingController();
  String aboutChurchString;
  TextEditingController churchWebsite = TextEditingController();
  String churchWebsiteString;
  TextEditingController parentChurch = TextEditingController();
  String parentChurchString;

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
  bool churchNotFound = false;
  bool hasChurch = true;

  String city;
  String address;
  String relationship;
  String title;
  String churchSelected;
  String churchNameString;
  UserEntity selectedChurch;

  int ministrySelected;
  int denominationSelected;
  String churchAddress;
  double churchLat;
  double churchLong;

  @override
  void initState() {
    _profileSettingsBloc = widget.initProfileSettingsBloc();
    _phoneLoginBloc = PhoneLoginBloc(widget.userRepository);
    _emailLoginBloc = EmailLoginBloc(widget.userRepository);

    _subscriptions = [
      Rx.merge([
        _profileSettingsBloc.message$,
        _phoneLoginBloc.message$,
        _emailLoginBloc.message$
      ]).listen(_showSettingsMessage)
    ];

    _profileSettingsBloc.settingState$.listen((event) {
      if(event.userEntity != null){
        firstName.text = event.userEntity.firstName;
        lastName.text = event.userEntity.lastName;

        if(event.userEntity.phoneNo != null){
          phoneNumber.text = event.userEntity.phoneNo.substring(event.userEntity.phoneNo.length - 10);
          _phoneLoginBloc.phoneNumberChanged(event.userEntity.phoneNo.substring(event.userEntity.phoneNo.length - 10));
          _profileSettingsBloc.setPhoneNumber(event.userEntity.phoneNo.substring(event.userEntity.phoneNo.length - 10));
        }

        aboutMe.text = event.userEntity.aboutMe;
        _emailLoginBloc.emailChanged(event.userEntity.email);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _profileSettingsBloc.dispose();
    _phoneLoginBloc.dispose();
    _emailLoginBloc.dispose();
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
            UserEntity user = state.userEntity;

            if(state.isLoading){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            _profileSettingsBloc.setFirstName(user.firstName);
            _profileSettingsBloc.setLastName(user.lastName);
            _profileSettingsBloc.setBio(user.aboutMe);
            _profileSettingsBloc.setRelationship(relationship ?? user.relationStatus);
            _profileSettingsBloc.setTitle(title ?? user.title);
            _profileSettingsBloc.setCity(city ?? user.city);
            _profileSettingsBloc.setAddress(address ?? user.businessAddress);

            if(isPublic == null){
              isPublic = user.isPublic && user.status == 0;
            }

            if(city == null){
              city = user.city;
            }

            if(address == null){
              address = user.businessAddress;
            }

            if(user.isChurch){
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
                                value: relationship ?? user.relationStatus,
                                isExpanded: true,
                                style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Nirmala', fontWeight: FontWeight.normal),
                                items: statusList,
                                onChanged: (s){
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
                                      value: title ?? user.title,
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
            UserEntity user = state.userEntity;

            if(state.isLoading){
              return Container();
            }

            if(user.isChurch){

              if(churchNameString == null){
                churchNameString = user.churchName;
                churchName.text = user.churchName;
                _profileSettingsBloc.setChurchName(churchNameString);
              }

              if(ministrySelected == null){
                ministrySelected = user.type;
                _profileSettingsBloc.setMinistryType(ministrySelected);
              }

              if(denominationSelected == null){
                denominationSelected = treeDenominations.indexOf(user.churchDenomination);
                _profileSettingsBloc.setChurchDenomination(user.churchDenomination);
              }

              if(churchAddress == null){
                churchAddress = user.churchAddress;
                _profileSettingsBloc.setLocationData([user.churchAddress, user.churchLat, user.churchLong]);
              }

              if(churchWebsiteString == null){
                churchWebsite.text = user.churchWebsite;
                churchWebsiteString = user.churchWebsite;
                _profileSettingsBloc.setChurchWebsite(user.churchWebsite);
              }

              if(parentChurchString == null){
                parentChurch.text = user.parentChurch;
                parentChurchString = user.parentChurch;
                _profileSettingsBloc.setParentChurch(user.parentChurch);
              }

              if(aboutChurchString == null){
                aboutChurch.text = user.aboutMe;
                aboutChurchString = user.aboutMe;
                _profileSettingsBloc.setBio(user.aboutMe);
              }

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, _, __) {
                                        return ListDialog(
                                          treeChurchMinistries,
                                        );
                                      }
                                  )
                              ).then((result) {
                                if (result != null) {
                                  setState(() {
                                    _profileSettingsBloc.setMinistryType(result);
                                    ministrySelected = result;
                                  });
                                }
                              });
                            },
                            color: Colors.black.withOpacity(.09),
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    church_icon,
                                    height: 24.0,
                                    width: 24.0,
                                    color: Colors.black.withOpacity(.4),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(
                                    ministrySelected != null && ministrySelected != -1 ? treeChurchMinistries[ministrySelected] : "What is your Ministry type?",
                                    style: TextStyle(
                                      fontFamily: 'Nirmala',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withOpacity(ministrySelected != null ? 1 : .6)
                                    ),
                                  ),
                                ],
                              ),
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    if (ministrySelected == 0)
                      adultMinistry()
                    else if (ministrySelected == 1)
                      youthMinistry(),
                    SizedBox(height: 10.0),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: (){},
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontFamily: "NirmalaB",
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                            color: Colors.white
                          )
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                    SizedBox(height: 50.0),
                  ],
                ),
              );
            }else{
              if(churchNameString == null){
                churchNameString = user.churchInfo?.churchName;
              }

              if(user.churchInfo != null && user.churchInfo.churchName != null && churchSelected == null){
                churchSelected = treeChurchAvailability[0];
                _profileSettingsBloc.setNoChurch(false);
                hasChurch = true;
              }

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (context, _, __) {
                                    return ListDialog(
                                      treeChurchAvailability,
                                    );
                                  }
                                )
                              ).then((result) {
                                if (result != null) {
                                  setState(() {
                                    churchSelected = treeChurchAvailability[result];
                                    hasChurch = result == 0;
                                    _profileSettingsBloc.setNoChurch(!hasChurch);
                                  });
                                }
                              });
                            },
                            color: Colors.black.withOpacity(.09),
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.help,
                                    color: Colors.black.withOpacity(.4),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(
                                    churchSelected ?? "Do you have a home church?",
                                    style: TextStyle(
                                      fontFamily: 'Nirmala',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withOpacity(churchSelected != null ? 1 : .6)
                                    ),
                                  ),
                                ],
                              ),
                          )
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    if (hasChurch) ...[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "CHURCH",
                            style: TextStyle(
                              fontFamily: 'Nirmala',
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                              color: Colors.black.withOpacity(.4)
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                church_icon,
                                height: 20,
                                width: 20,
                                color: Colors.black.withOpacity(.4),
                              ),
                              SizedBox(width: 10.0),
                              Flexible(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/search', arguments: "church").then((result){
                                      var church = result as UserEntity;
                                      _profileSettingsBloc.setChurch(church);
                                      setState(() {
                                        selectedChurch = church;
                                        churchNameString = church.churchName;
                                        churchName.text = church.churchName;
                                      });
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
                                            churchNotFound || (churchNameString ?? "").isEmpty ? "Search for your church" : churchNameString,
                                            style: TextStyle(
                                              fontFamily: 'Nirmala',
                                              fontSize: 17.0,
                                              color: Colors.black.withOpacity(churchNotFound || (churchNameString ?? "").isEmpty ? .2 : 1),
                                              fontWeight: FontWeight.normal
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.0)
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
                              )
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
                      if (!churchNotFound && churchName.text.isNotEmpty) ...[
                        TextField(
                          controller: churchID,
                          onChanged: (s){
                            _profileSettingsBloc.setChurchId(s);
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.grey[50],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Colors.black.withOpacity(.1))
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Colors.black.withOpacity(.1))
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Colors.black.withOpacity(.1))
                            ),
                            hintText: "Enter Church ID"
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.warning,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10.0),
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                      fontFamily: "Nirmala",
                                      fontWeight: FontWeight.normal
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "If you do not know the Church ID please visit your church and ask for their  "
                                      ),
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          fontFamily: "Nirmala",
                                          fontWeight: FontWeight.normal
                                        ),
                                        text: "Tree ID."
                                      ),
                                    ]
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                    color: churchNotFound ? Theme.of(context).primaryColor : Colors.transparent,
                                    border: Border.all(color: churchNotFound ? Theme.of(context).primaryColor : Colors.transparent)
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(width: 2, color: churchNotFound ? Theme.of(context).primaryColor : Colors.grey)
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Flexible(
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      churchName.clear();
                                      churchNotFound = !churchNotFound;
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
                                            "Unable to find your church?",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black.withOpacity(churchNotFound ? 1 : .2)
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
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
                      if (churchNotFound) ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "CHURCH NAME",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NirmalaB',
                                fontSize: 12.0,
                                color: Colors.black.withOpacity(.4)
                              )
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Image.asset(
                                    church_icon,
                                    height: 18,
                                    width: 18,
                                    color: Colors.black.withOpacity(.4),
                                  )
                                ),
                                SizedBox(width: 10.0),
                                Flexible(
                                  child: TextField(
                                    textInputAction: TextInputAction.done,
                                    textCapitalization: TextCapitalization.none,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter your home church name",
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Nirmala',
                                        fontSize: 17.0,
                                        color: Colors.black.withOpacity(0.2)
                                      )
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Nirmala',
                                      fontSize: 20.0,
                                      color: Colors.black
                                    ),
                                    cursorColor: Colors.black,
                                    cursorWidth: 1,
                                    maxLines: 1,
                                    controller: churchName,
                                    onChanged: (s){
                                      _profileSettingsBloc.setUnknownChurch(s);
                                    },
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
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.warning,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10.0),
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                      fontFamily: "Nirmala",
                                      fontWeight: FontWeight.normal
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Please note: If you don't have a church name type "
                                      ),
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          fontFamily: "Nirmala",
                                          fontWeight: FontWeight.normal
                                        ),
                                        text: "NONE"
                                      ),
                                      TextSpan(
                                        text: " instead of leaving it blank."
                                      ),
                                    ]
                                  )
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ],
                    SizedBox(height: 30.0),
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
                            fontSize: 22.0,
                            color: Colors.white,
                            fontFamily: 'NirmalaB',
                            fontWeight: FontWeight.bold
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
        ),
      ),
    );
  }

  youthMinistry() {
    return Column(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "CHURCH NAME",
              style: TextStyle(
                fontFamily: 'NirmalaB',
                fontSize: 12.0,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold
              )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Image.asset(
                    church_icon,
                    width: 23.0,
                    height: 23.0,
                    color: Colors.black.withOpacity(.4),
                  ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Youth Ministry Name",
                      hintStyle: TextStyle(
                        fontFamily: 'Nirmala',
                        fontSize: 17.0,
                        color: Colors.black.withOpacity(.2),
                        fontWeight: FontWeight.normal
                      )
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
                    onChanged: (value){
                      setState(() {
                        _profileSettingsBloc.setChurchName(value);
                        churchNameString = value;
                      });
                    },
                    controller: churchName,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(.1),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            )
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "DENOMINATION",
              style: TextStyle(
                fontFamily: "NirmalaB",
                fontSize: 12.0,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10.0),
            FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) {
                            return ListDialog(
                              treeDenominations,
                            );
                          }
                      )
                  ).then((result) {
                    if (result != null) {
                      setState(() {
                        _profileSettingsBloc.setChurchDenomination(treeDenominations[result]);
                        denominationSelected = result;
                      });
                    }
                  });
                },
                color: Colors.black.withOpacity(.09),
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        church_icon,
                        height: 24.0,
                        width: 24.0,
                        color: Colors.black.withOpacity(.4),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        denominationSelected != null ? treeDenominations[denominationSelected] : "What is your denomination?",
                        style: TextStyle(
                          fontFamily: 'Nirmala',
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black.withOpacity(denominationSelected != null ? 1 : .6)
                        ),
                      ),
                    ],
                  ),
                )
            ),
            SizedBox(height: 10.0),
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "LOCATION",
              style: TextStyle(
                fontFamily: "NirmalaB",
                fontSize: 12.0,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold
              )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.location_on,
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

                      setState(() {
                        churchAddress = result.address;
                        churchLat = result.latLng.latitude;
                        churchLong = result.latLng.longitude;
                        _profileSettingsBloc.setLocationData([churchAddress, churchLat, churchLong]);
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
                              churchAddress == null ? "Where is your church located?" : churchAddress,
                              style: TextStyle(
                                fontFamily: 'Nirmala',
                                fontSize: 17.0,
                                color: Colors.black.withOpacity(churchAddress == null ? (.2) : 1),
                                fontWeight: FontWeight.normal
                              )
                            ),
                          ),
                          SizedBox(width: 10.0),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
              ],
            ),
            Container(
              height: 1,
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
              "MINISTRY BIO",
              style: TextStyle(
                fontFamily: 'NirmalaB',
                fontSize: 12.0,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold
              )
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
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Describe your ministry (Optional)",
                      hintStyle: TextStyle(
                        fontFamily: 'Nirmala',
                        fontSize: 17.0,
                        color: Colors.black.withOpacity(.2),
                        fontWeight: FontWeight.normal
                      )
                    ),
                    style: TextStyle(
                      fontFamily: 'Nirmala',
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal
                    ),
                    cursorColor: Colors.black,
                    cursorWidth: 1,
                    maxLines: 3,
                    onChanged: (value){
                      _profileSettingsBloc.setBio(value);
                      aboutChurchString = value;
                    },
                    controller: aboutChurch,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
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
              "WEBSITE",
              style: TextStyle(
                fontFamily: 'NirmalaB',
                fontSize: 12.0,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold
              )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Icon(
                    Icons.vpn_lock,
                    size: 23,
                    color: Colors.black.withOpacity(.4),
                  ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Website Address",
                      hintStyle: TextStyle(
                        fontFamily: 'Nirmala',
                        fontSize: 17.0,
                        color: Colors.black.withOpacity(.2),
                        fontWeight: FontWeight.normal
                      )
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
                    onChanged: (value){
                      setState(() {
                        _profileSettingsBloc.setChurchWebsite(value);
                        churchWebsiteString = value;
                      });
                    },
                    controller: churchWebsite,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
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
              "PARENT CHURCH",
              style: TextStyle(
                fontFamily: 'NirmalaB',
                fontSize: 12.0,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold
              )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Image.asset(
                    church_icon,
                    width: 23.0,
                    height: 23.0,
                    color: Colors.black.withOpacity(.4),
                  ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Parent Church",
                      hintStyle: TextStyle(
                        fontFamily: 'Nirmala',
                        fontSize: 17.0,
                        color: Colors.black.withOpacity(.2),
                        fontWeight: FontWeight.normal
                      )
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
                    onChanged: (value){
                      setState(() {
                        _profileSettingsBloc.setParentChurch(value);
                        parentChurchString = value;
                      });
                    },
                    controller: parentChurch,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(.1),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            )
          ],
        ),
      ],
    );
  }

  adultMinistry() {
    return Column(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                "CHURCH NAME",
                style: TextStyle(
                    fontFamily: 'NirmalaB',
                    fontSize: 12.0,
                    color: Colors.black.withOpacity(.4),
                    fontWeight: FontWeight.bold
                )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Image.asset(
                    church_icon,
                    width: 23.0,
                    height: 23.0,
                    color: Colors.black.withOpacity(.4),
                  ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Youth Ministry Name",
                        hintStyle: TextStyle(
                            fontFamily: 'Nirmala',
                            fontSize: 17.0,
                            color: Colors.black.withOpacity(.2),
                            fontWeight: FontWeight.normal
                        )
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
                    onChanged: (value){
                      setState(() {
                        _profileSettingsBloc.setChurchName(value);
                        churchNameString = value;
                      });
                    },
                    controller: churchName,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(.1),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            )
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "DENOMINATION",
              style: TextStyle(
                  fontFamily: "NirmalaB",
                  fontSize: 12.0,
                  color: Colors.black.withOpacity(.4),
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10.0),
            FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) {
                            return ListDialog(
                              treeDenominations,
                            );
                          }
                      )
                  ).then((result) {
                    if (result != null) {
                      setState(() {
                        _profileSettingsBloc.setChurchDenomination(treeDenominations[result]);
                        denominationSelected = result;
                      });
                    }
                  });
                },
                color: Colors.black.withOpacity(.09),
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        church_icon,
                        height: 24.0,
                        width: 24.0,
                        color: Colors.black.withOpacity(.4),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        denominationSelected != null ? treeDenominations[denominationSelected] : "What is your denomination?",
                        style: TextStyle(
                            fontFamily: 'Nirmala',
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(denominationSelected != null ? 1 : .6)
                        ),
                      ),
                    ],
                  ),
                )
            ),
            SizedBox(height: 10.0),
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                "LOCATION",
                style: TextStyle(
                    fontFamily: "NirmalaB",
                    fontSize: 12.0,
                    color: Colors.black.withOpacity(.4),
                    fontWeight: FontWeight.bold
                )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.location_on,
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

                      setState(() {
                        churchAddress = result.address;
                        churchLat = result.latLng.latitude;
                        churchLong = result.latLng.longitude;
                        _profileSettingsBloc.setLocationData([churchAddress, churchLat, churchLong]);
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
                                churchAddress == null ? "Where is your church located?" : churchAddress,
                                style: TextStyle(
                                    fontFamily: 'Nirmala',
                                    fontSize: 17.0,
                                    color: Colors.black.withOpacity(churchAddress == null ? (.2) : 1),
                                    fontWeight: FontWeight.normal
                                )
                            ),
                          ),
                          SizedBox(width: 10.0),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
              ],
            ),
            Container(
              height: 1,
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
                "MINISTRY BIO",
                style: TextStyle(
                    fontFamily: 'NirmalaB',
                    fontSize: 12.0,
                    color: Colors.black.withOpacity(.4),
                    fontWeight: FontWeight.bold
                )
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
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Describe your ministry (Optional)",
                        hintStyle: TextStyle(
                            fontFamily: 'Nirmala',
                            fontSize: 17.0,
                            color: Colors.black.withOpacity(.2),
                            fontWeight: FontWeight.normal
                        )
                    ),
                    style: TextStyle(
                        fontFamily: 'Nirmala',
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.normal
                    ),
                    cursorColor: Colors.black,
                    cursorWidth: 1,
                    maxLines: 3,
                    onChanged: (value){
                      _profileSettingsBloc.setBio(value);
                      aboutChurchString = value;
                    },
                    controller: aboutChurch,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
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
                "WEBSITE",
                style: TextStyle(
                    fontFamily: 'NirmalaB',
                    fontSize: 12.0,
                    color: Colors.black.withOpacity(.4),
                    fontWeight: FontWeight.bold
                )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Icon(
                    Icons.vpn_lock,
                    size: 23,
                    color: Colors.black.withOpacity(.4),
                  ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Website Address",
                        hintStyle: TextStyle(
                            fontFamily: 'Nirmala',
                            fontSize: 17.0,
                            color: Colors.black.withOpacity(.2),
                            fontWeight: FontWeight.normal
                        )
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
                    onChanged: (value){
                      setState(() {
                        _profileSettingsBloc.setChurchWebsite(value);
                        churchWebsiteString = value;
                      });
                    },
                    controller: churchWebsite,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
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
                "PARENT CHURCH",
                style: TextStyle(
                    fontFamily: 'NirmalaB',
                    fontSize: 12.0,
                    color: Colors.black.withOpacity(.4),
                    fontWeight: FontWeight.bold
                )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Image.asset(
                    church_icon,
                    width: 23.0,
                    height: 23.0,
                    color: Colors.black.withOpacity(.4),
                  ),
                ),
                SizedBox(width: 10.0),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Parent Church",
                        hintStyle: TextStyle(
                            fontFamily: 'Nirmala',
                            fontSize: 17.0,
                            color: Colors.black.withOpacity(.2),
                            fontWeight: FontWeight.normal
                        )
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
                    onChanged: (value){
                      setState(() {
                        _profileSettingsBloc.setParentChurch(value);
                        parentChurchString = value;
                      });
                    },
                    controller: parentChurch,
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(.1),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            )
          ],
        ),
      ],
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CountryCodeModal();
                              },
                            ).then((country) {
                              if (country != null) {
                                var selectedCountry = country as Country;
                                _profileSettingsBloc.countryCodeChanged(selectedCountry.phoneCode);
                                _phoneLoginBloc.countryCodeChanged(selectedCountry.phoneCode);
                              }
                            });
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
                                "+1",
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
                                  onChanged: (number){
                                    var cleaned = number.replaceAll(" ", "").replaceAll("(", "").replaceAll(")", "").replaceAll("-", "");
                                    _phoneLoginBloc.phoneNumberChanged(number);
                                    _profileSettingsBloc.setPhoneNumber(cleaned);
                                  },
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
                                onChanged: _emailLoginBloc.passwordChanged,
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
                          _emailLoginBloc.submitLogin();
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

  void _returnedFromVerification(Object message){
    if(message is PhoneVerificationSuccess){
      _profileSettingsBloc.saveChanges();
    }else{
      _showSnackBar("There was a problem verifying your phone number");
    }
  }

  void _showSettingsMessage(dynamic message){
    final s = S.of(context);

    if (message is SettingsMessageSuccess) {
      _showSnackBar("Changes saved!");
    }

    if (message is LoginMessageSuccess) {
      _phoneLoginBloc.submitLogin();
    }

    if(message is LoginPhoneSuccess){
      Navigator.of(context).pushNamed(
        '/phone_verification',
        arguments: [message.verificationId, true],
      ).then(_returnedFromVerification);
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
      if (error is WeakPasswordError) {
        _showSnackBar(s.weak_password_error);
      }
      if (error is UnknownLoginError) {
        _showSnackBar(s.error_occurred);
      }
    }
  }
}