import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
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
        print(snapshot.data);



        return Scaffold(
          body: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _appBar(),
                  _profile(),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _appBar() {
    return InkWell(
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
                image: CacheImage(''),
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
                  padding: EdgeInsets.only(
                    left: 15, 
                    right: 15, 
                    bottom: 10
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                'Chuch or name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            // TODO: if verified show verified icon
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.white,
                            onPressed: () {

                            },
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                width: 1,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            child: Text(
                              '0 Shares',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          RaisedButton(
                            color: Colors.white,
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            onPressed: () {
                              // TODO: view connections
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                width: 1,
                                color: Colors.blue,
                              ),
                            ),
                            child: Text(
                              '',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          // TODO: show connect button
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _profile() {
    return Column(
      children: <Widget>[
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
              // TODO: show status if own profile
              SizedBox(height: 15),
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
                    Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}