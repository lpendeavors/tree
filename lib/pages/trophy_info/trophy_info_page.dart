import 'dart:async';

import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import './trophy_info_bloc.dart';
import './trophy_info_state.dart';

class TrophyInfoPage extends StatefulWidget {
  final TrophyInfoBloc Function() initTrophyInfoBloc;

  const TrophyInfoPage({
    Key key,
    @required this.initTrophyInfoBloc,
  }) : super(key: key);

  @override
  _TrophyInfoPageState createState() => _TrophyInfoPageState();
}

class _TrophyInfoPageState extends State<TrophyInfoPage>{
  TrophyInfoBloc _trophiesBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _trophiesBloc = widget.initTrophyInfoBloc();
  }

  @override
  void dispose() {
    _trophiesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder<TrophyInfoState>(
          stream: _trophiesBloc.trophyInfoState$,
          initialData: _trophiesBloc.trophyInfoState$.value,
          builder: (context, snapshot){
            var data = snapshot.data;
            var trophy = data.trophy;
            var unlocked = trophy.trophyCount.length == trophy.trophyUnlockAt;

            if (data.error != null) {
              print('error ${data.error}');
              return Center(
                child: Text(
                  S.of(context).error_occurred,
                ),
              );
            }

            if (data.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Stack(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                              child: Image.asset(
                                "assets/images/trophy_main.png",
                                color: Colors.white,
                              )
                            ),
                            if (!unlocked)
                              Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: Icon(
                                  unlocked ? Icons.lock_open : Icons.lock_outline,
                                  size: 18,
                                  color: Colors.white,
                                )
                              ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Trophy Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black,
                            fontFamily: 'NirmalaB',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.0),
                        Stack(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0x10000000),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                )
                              ),
                              child: Image.asset(
                                trophy.trophyIcon,
                                height: 150,
                              ),
                            ),
                            if (unlocked)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[800],
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Achieved",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                    fontFamily: 'Nirmala',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(0.0),
                          child: new Card(
                              color: Colors.grey[500],
                              elevation: .5,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: new Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.info,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5.0),
                                        Text(
                                          "",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontFamily: 'NirmalaB',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      "You have to ${trophy.trophyInfo.toLowerCase()} to unlock this trophy",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Nirmala',
                                        color: Colors.white
                                      )
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(height: 10.0)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 15),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                        fontFamily: 'NirmalaB',
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}