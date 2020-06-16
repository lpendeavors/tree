import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import 'package:flutter/services.dart';
import '../../util/asset_utils.dart';
import '../../generated/l10n.dart';
import './connections_bloc.dart';
import './connections_state.dart';
import '../../user_bloc/user_bloc.dart';

class ConnectionsPage extends StatefulWidget {
  final ConnectionsBloc Function() initConnectionsBloc;

  const ConnectionsPage({
    Key key,
    @required this.initConnectionsBloc,
  }) : super(key: key);

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage>{
  ConnectionsBloc _connectionsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _connectionsBloc = widget.initConnectionsBloc();
  }

  @override
  void dispose() {
    _connectionsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder<ConnectionsState>(
          stream: _connectionsBloc.connectionsState$,
          initialData: _connectionsBloc.connectionsState$.value,
          builder: (context, snapshot){
            var data = snapshot.data;

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

            return ListView.builder(
              itemCount: data.connectionItems.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return _userItem(data.connectionItems[index]);
              },
            );
          },
        ),
      ),
      appBar: AppBar(
        title: Text("Connections"),
      ),
    );
  }

  Widget _userItem(ConnectionItem user){
    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed(
          '/profile',
          arguments: user.uid
        );
      },
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: (){},
              child: ClipRRect(
                child: AnimatedContainer(
                  curve: Curves.ease,
                  alignment: Alignment.center,
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                  width: 60.0,
                  height: 60.0,
                  child: Stack(
                    children: <Widget>[
                      new Card(
                        margin: EdgeInsets.all(0),
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        elevation: 0.5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: 60.0,
                              height: 60.0,
                              child: Center(child: Icon(Icons.person, color: Colors.white, size: 14.0)),
                            ),
                            Image(
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                              image: CacheImage(user.photo),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.0),
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          user.isChurch ? user.churchName : user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (user.isChurch)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              church_icon,
                              height: 25.0,
                              width: 25.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        SizedBox(height: 5.0),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      user.aboutMe,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.0,
                        fontFamily: 'Nirmala',
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}