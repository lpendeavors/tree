import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import '../../models/old/trophy.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './profile_bloc.dart';
import './profile_state.dart';

class ProfilePage extends StatefulWidget {
  final UserBloc userBloc;
  final ProfileBloc Function() initProfileBloc;
  final bool isTab;

  const ProfilePage({
    Key key,
    @required this.userBloc,
    @required this.initProfileBloc,
    @required this.isTab,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc _profileBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _profileBloc = widget.initProfileBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _profileBloc.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileState>(
      stream: _profileBloc.profileState$,
      initialData: _profileBloc.profileState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _appBar(data),
                _profile(data),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _appBar(ProfileState data) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            // Add or view image
          },
          child: Container(
            height: 300,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Image(
                    image: CacheImage(data.profile.photo),
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (widget.isTab) ...[
                      SafeArea(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                        ),
                      ),
                    ],
                    if (!widget.isTab) ...[
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            BackButton(
                              color: Colors.white,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Connect, report, block
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        data.profile.isChurch ? data.profile.churchName : data.profile.fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NirmalaB'
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    if(data.profile.isVerified) ...[Image.asset(
                                      verified_icon,
                                      height: 25,
                                      width: 25,
                                      color: Color(0xFF9CC83F),
                                    )]
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        RaisedButton(
                                          color: Colors.white,
                                          onPressed: (){},
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              width: 1,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          child: Text(
                                            '${data.profile.shares.length} Shares',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        RaisedButton(
                                          onPressed: () {
                                            // TODO: view connections
                                          },
                                          color: Colors.white,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              width: 1,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          child: Text(
                                            '${data.profile.connections.length} Connections',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    // TODO: show connect button
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Achievements",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NirmalaB'
                          )
                        ),
                        Text(
                          "${data.profile.trophies.where((element) => element.trophyUnlocked ?? false).length} Unlocked",
                          style: TextStyle(fontSize: 14.0, fontFamily: 'Nirmala', color: Colors.black54),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        //TODO: Open Trophy Page
                      },
                      child: Text(
                        "View Trophies",
                        style: TextStyle(fontSize: 12.0, fontFamily: 'Nirmala', color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5
                ),
                itemBuilder: (c, index) {
                  Trophy trophy = data.profile.trophies[index];
                  String icon = trophy.trophyIcon;
                  int unlockAt = trophy.trophyUnlockAt;
                  int count = trophy.trophyCount.length;
                  bool unlocked = count == unlockAt;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        //TODO: Trophy Details
                      },
                      radius: 10,
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              icon,
                              height: 50,
                            ),
                          ),
                          //if (!unlocked)
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(unlocked ? 0.1 : 0.9)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                //stops: [0.1, 0.1]
                              )),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.all(8),
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: unlocked ? Colors.green : Colors.red
                              ),
                              child: Icon(
                                unlocked ? Icons.lock_open : Icons.lock_outline,
                                size: 18,
                                color: Colors.white,
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.all(8),
                itemCount: data.profile.trophies.length > 8 ? 8 : data.profile.trophies.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _profile(ProfileState data) {
    return Column(
      children: <Widget>[
        if(data.profile.isChurch) ...[
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 0.8,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 0.2,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Bio",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.5)
                            ),
                          ),
                          Text(
                            "${data.profile.type == 1 ? "Youth Church" : "Adult Church"}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.5)
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _bioRow(church_icon, data.profile.churchName ?? "", isAsset: true, color: Theme.of(context).primaryColor),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.add_circle, data.profile.churchDenomination ?? "", color: Colors.purple),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.location_on, data.profile.churchAddress ?? "", color: Colors.blue),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.info, data.profile.aboutMe ?? "", color: Colors.orange)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        if(!data.profile.isChurch) ...[
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 0.8,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 0.2,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Bio",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.5)
                            ),
                          ),
                          if (data.profile.isVerified)
                            Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Title: " + data.profile.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.5)
                                ),
                              ),
                            ),
                        ],
                      ),

                      if(data.profile.churchInfo != null) ...[
                        _bioRow(church_icon, data.profile.churchInfo.churchName, isAsset: true),
                        Container(
                          height: 1.0,
                          width: double.infinity,
                          color: Colors.black12,
                          margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                        ),
                      ],
                      _bioRow(Icons.location_on, data.profile.city, color: Colors.blue),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow((data.profile.relationStatus != 'Dating' ? data.profile.relationStatus != 'Married' ? single_icon : married_icon : dating_icon), data.profile.relationStatus, isAsset: true),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.info, data.profile.aboutMe, color: Colors.orange)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _bioRow(icon, title, {Color color, bool isAsset = false}){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 30,
          width: 30,
          padding: EdgeInsets.all(2),
          child: Center(
              child: isAsset ? Image.asset(
                icon,
                color: Theme.of(context).primaryColor,
                height: 20,
              ) : Icon(
                icon,
                size: 20,
                color: color ?? Colors.black.withOpacity(0.6),
              )
          ),
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            title ?? 'error',
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w300
            )
          ),
        ),
      ],
    );
  }
}