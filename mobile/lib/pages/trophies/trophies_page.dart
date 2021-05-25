import 'dart:async';

import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import './trophies_bloc.dart';
import './trophies_state.dart';

class TrophiesPage extends StatefulWidget {
  final TrophiesBloc Function() initTrophiesBloc;

  const TrophiesPage({
    Key key,
    @required this.initTrophiesBloc,
  }) : super(key: key);

  @override
  _TrophiesPageState createState() => _TrophiesPageState();
}

class _TrophiesPageState extends State<TrophiesPage>{
  TrophiesBloc _trophiesBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _trophiesBloc = widget.initTrophiesBloc();
  }

  @override
  void dispose() {
    _trophiesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trophies"),
      ),
      body: Container(
        child: StreamBuilder<TrophiesState>(
          stream: _trophiesBloc.trophiesState$,
          initialData: _trophiesBloc.trophiesState$.value,
          builder: (context, snapshot){
            var data = snapshot.data;

            if (data.error != null) {
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

            return GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.3, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemBuilder: (c, index) {
                var trophy = data.trophies[index];
                var unlocked = trophy.trophyCount.length == trophy.trophyUnlockAt;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/trophy_info',
                        arguments: index
                      );
                    },
                    radius: 10,
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            trophy.trophyIcon,
                            height: 50,
                          ),
                        ),
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
                            )
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: unlocked ? Colors.green : Colors.red),
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
              itemCount: data.trophies.length,
            );
          },
        ),
      ),
    );
  }
}