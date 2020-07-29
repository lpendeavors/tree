import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../util/permission_utils.dart';
import '../../widgets/modals/profile_image_modal.dart';
import '../../widgets/modals/cancel_request_modal.dart';
import '../../widgets/modals/disconnect_modal.dart';
import '../../generated/l10n.dart';
import '../../pages/feed/widgets/feed_list_item.dart';
import '../../models/old/trophy.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  ProfileBloc _profileBloc;
  List<StreamSubscription> _subscriptions;
  bool showChurchBroadcast = true;
  bool showProfileBroadcast = true;

  @override
  void initState() {
    super.initState();

    _profileBloc = widget.initProfileBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<ProfileState>(
                stream: _profileBloc.profileState$,
                initialData: _profileBloc.profileState$.value,
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (!data.isLoading) {
                    return Column(
                      children: <Widget>[
                        _appBar(data),
                        _profile(data),
                      ],
                    );
                  } else {
                    return Container(
                      height: 800,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }),
            StreamBuilder<RecentFeedState>(
                stream: _profileBloc.recentFeedState$,
                initialData: _profileBloc.recentFeedState$.value,
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (!data.isLoading) {
                    return Column(
                      children: <Widget>[
                        _recentPostList(data),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
      // print(data.profile);

      // if (data.isLoading) {
      //   return Center(
      //     child: CircularProgressIndicator(),
      //   );
      // }

      // if (data.error != null) {
      //   print(data.error);
      //   return Center(
      //     child: Text(
      //       S.of(context).error_occurred,
      //     ),
      //   );
      // }

      // return Scaffold(
      //   body: SingleChildScrollView(
      //     physics: BouncingScrollPhysics(),
      //     child: Column(
      //       children: <Widget>[
      //         _appBar(data),
      //         _profile(data),
      //         _recentPostList(data)
      //       ],
      //     ),
      //   ),
      // );
      // }
    );
  }

  Widget _appBar(ProfileState data) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ProfileImageModal(
                      options: data.profile.myProfile
                          ? data.profile.photo.length > 0
                              ? ["View Picture", "Update Picture"]
                              : ["Add Photo"]
                          : [
                              "View Picture",
                              if (data.isAdmin) "Approve Account"
                            ]);
                }).then((result) async {
              if (result == "Add Photo" || result == "Update Picture") {
                bool hasPermission = await checkMediaPermission();
                if (hasPermission) {
                  var file = await ImagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  var cropped = await ImageCropper.cropImage(
                    sourcePath: file.path,
                  );
                  _profileBloc.setPhoto(cropped);
                }
                return;
              }

              if (result == "View Picture") {
                Navigator.of(context).pushNamed(
                  '/preview_image',
                  arguments: data.profile.photo,
                );
                return;
              }

              if (result == "Approve Account") {
                _profileBloc.approveAccount();
                return;
              }
            });
          },
          child: Container(
            height: 300,
            child: Stack(
              children: <Widget>[
                Container(
                  height: 300,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                      child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white70,
                  )),
                ),
                if (data.profile.photo.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.center,
                    child: CachedNetworkImage(
                      imageUrl: data.profile.photo,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
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
                    if (data.profile.myProfile) ...[
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
                    if (!data.profile.myProfile) ...[
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
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ProfileImageModal(options: [
                                        "Report User",
                                        "Block User"
                                      ]);
                                    }).then((value) {
                                  //broken in original app too
                                });
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
                                        data.profile.isChurch
                                            ? data.profile.churchName
                                            : data.profile.fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NirmalaB'),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    if (data.profile.isVerified) ...[
                                      Image.asset(
                                        verified_icon,
                                        height: 25,
                                        width: 25,
                                        color: Color(0xFF9CC83F),
                                      )
                                    ]
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        RaisedButton(
                                          color: Colors.white,
                                          onPressed: () {},
                                          padding: EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 5,
                                              bottom: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                              width: 1,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          child: Text(
                                            '${data.profile.shares.length} Shares',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        RaisedButton(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              '/connections',
                                              arguments: data.profile.uid,
                                            );
                                          },
                                          color: Colors.white,
                                          padding: EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 5,
                                              bottom: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                    ),
                                    if (!data.profile.myProfile)
                                      _connectButton(data.profile)
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
        if (!data.profile.myProfile && data.profile.isFriend)
          RaisedButton(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Send Direct Message",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Icon(
                    Icons.navigate_next,
                    color: Colors.white.withOpacity(0.7),
                    size: 15,
                  ),
                ],
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                //TODO: Action
              }),
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
                        Text("Achievements",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NirmalaB')),
                        Text(
                          "${data.profile.trophies.where((element) => element.trophyCount.length == element.trophyUnlockAt).length} Unlocked",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Nirmala',
                              color: Colors.black54,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/trophies',
                          arguments: data.profile.uid,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 4.0, right: 4.0),
                        child: Text(
                          "View Trophies",
                          style: TextStyle(
                              fontSize: 12.0,
                              fontFamily: 'Nirmala',
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5),
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
                        Navigator.of(context)
                            .pushNamed('/trophy_info', arguments: index);
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
                                    Colors.black
                                        .withOpacity(unlocked ? 0.1 : 0.9)
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
                                    color:
                                        unlocked ? Colors.green : Colors.red),
                                child: Icon(
                                  unlocked
                                      ? Icons.lock_open
                                      : Icons.lock_outline,
                                  size: 18,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.all(8),
                itemCount: data.profile.trophies.length > 8
                    ? 8
                    : data.profile.trophies.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _connectButton(ProfileItem profileItem) {
    bool connected = profileItem.isFriend;
    bool received = profileItem.received;
    bool sent = profileItem.sent;

    if (received) {
      return RaisedButton(
        onPressed: () {
          _profileBloc.acceptConnectRequest();
        },
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.check, color: Colors.white, size: 15),
            SizedBox(width: 5),
            Text(
              "Respond",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (connected) {
      return RaisedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DisconnectModal();
              }).then((disconnect) {
            if (disconnect) {
              _profileBloc.disconnect();
            }
          });
        },
        color: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: <Widget>[
            Icon(Icons.remove_circle, color: Colors.white, size: 15),
            SizedBox(width: 5),
            Text(
              "UnConnect",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (sent) {
      return RaisedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CancelRequestModal();
              }).then((cancel) {
            if (cancel) {
              _profileBloc.cancelConnectRequest();
            }
          });
        },
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.pause_circle_filled,
                color: Theme.of(context).primaryColor, size: 15),
            SizedBox(width: 5),
            Text(
              "Pending",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      );
    }

    return RaisedButton(
      onPressed: () {
        _profileBloc.sendConnectRequest();
      },
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.add_circle, color: Colors.white, size: 15),
          SizedBox(width: 5),
          Text(
            "Connect",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  _profileStatusNotifier(ProfileItem profile) {
    if (!profile.myProfile) {
      return Container();
    }

    if (!profile.isChurchUpdated && showChurchBroadcast) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "Information Needed",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(.7)),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(),
                    flex: 1,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showChurchBroadcast = false;
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      //size: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                "Your Church information needs to be updated",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/update_info', arguments: 1);
                },
                color: Colors.white,
                padding: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    "Update Information",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else if (!profile.isProfileUpdated &&
        !profile.isChurch &&
        showProfileBroadcast) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "Information Needed",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(.7)),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(),
                    flex: 1,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showProfileBroadcast = false;
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      //size: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                "Your Personal information needs to be updated",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/update_info', arguments: 0);
                },
                color: Colors.white,
                padding: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    "Update Information",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _profile(ProfileState data) {
    return Column(
      children: <Widget>[
        if (data.profile.isChurch) ...[
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
                if ((showChurchBroadcast || showProfileBroadcast) &&
                    !data.profile.isChurchUpdated) ...[
                  _profileStatusNotifier(data.profile),
                  SizedBox(height: 15.0)
                ],
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
                      if (data.profile.myProfile) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: "Church ID:  ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(.5))),
                              TextSpan(
                                  text: data.profile.uid
                                      .substring(0, 7)
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ])),
                            //Flexible(child: Text(userModel.getString(TIME_UPDATED))),
                            RaisedButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: data.profile.uid
                                        .substring(0, 7)
                                        .toUpperCase()));
                              },
                              color: Colors.blue,
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(width: 1, color: Colors.blue),
                              ),
                              child: Text(
                                "Copy",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 1.0,
                          width: double.infinity,
                          color: Colors.black12,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Bio",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.5)),
                          ),
                          Text(
                            "${data.profile.type == 1 ? "Youth Ministry" : "Adult Ministry"}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _bioRow(church_icon, data.profile.churchName,
                          isAsset: true, color: Theme.of(context).primaryColor),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.add_circle, data.profile.churchDenomination,
                          color: Colors.purple),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.location_on, data.profile.churchAddress,
                          color: Colors.blue),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.info, data.profile.aboutMe,
                          color: Colors.orange)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!data.profile.isChurch) ...[
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
                if ((showChurchBroadcast || showProfileBroadcast) &&
                    (!data.profile.isChurchUpdated ||
                        !data.profile.isProfileUpdated)) ...[
                  _profileStatusNotifier(data.profile),
                  SizedBox(height: 5.0)
                ],
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
                                color: Colors.black.withOpacity(0.5)),
                          ),
                          if (data.profile.isVerified)
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Title: " + data.profile.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                            ),
                        ],
                      ),
                      if (data.profile.churchInfo != null) ...[
                        _bioRow(church_icon, data.profile.churchInfo.churchName,
                            isAsset: true),
                        Container(
                          height: 1.0,
                          width: double.infinity,
                          color: Colors.black12,
                          margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                        ),
                      ],
                      _bioRow(Icons.location_on, data.profile.city,
                          color: Colors.blue),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(
                          (data.profile.relationStatus != 'Dating'
                              ? data.profile.relationStatus != 'Married'
                                  ? single_icon
                                  : married_icon
                              : dating_icon),
                          data.profile.relationStatus,
                          isAsset: true),
                      Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.black12,
                        margin: EdgeInsets.fromLTRB(40, 5, 0, 5),
                      ),
                      _bioRow(Icons.info, data.profile.aboutMe,
                          color: Colors.orange)
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

  Widget _bioRow(icon, title, {Color color, bool isAsset = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 30,
          width: 30,
          padding: EdgeInsets.all(2),
          child: Center(
              child: isAsset
                  ? Image.asset(
                      icon,
                      color: Theme.of(context).primaryColor,
                      height: 20,
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: color ?? Colors.black.withOpacity(0.6),
                    )),
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(title,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w300)),
        ),
      ],
    );
  }

  Widget _recentPostList(RecentFeedState data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (data.feedItems.length > 0) ...[
          Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              child: Text(
                "Posts",
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.bold),
              )),
          ...List.generate(data.feedItems.length, (index) {
            return FeedListItem(
              context: context,
              tickerProvider: this,
              feedItem: data.feedItems[index],
              likeFeedItem: (item) {
                // TODO: finish saving like
                // _feedBloc.postToLikeChanged(item);
                // _feedBloc.likePostChanged(!data.feedItems[index].isLiked);
                // _feedBloc.saveLikeValue();
              },
            );
          })
        ]
      ],
    );
  }
}
