import 'dart:async';

import 'package:flutter/material.dart';
import 'package:treeapp/generated/l10n.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../widgets/image_holder.dart';
import './poll_responders_bloc.dart';
import './poll_responders_state.dart';

class PollRespondersPage extends StatefulWidget {
  final UserBloc userBloc;
  final PollRespondersBloc Function() initPollRespondersBloc;

  const PollRespondersPage({
    Key key,
    @required this.userBloc,
    @required this.initPollRespondersBloc,
  }) : super(key: key);

  @override
  _PollRespondersPageState createState() => _PollRespondersPageState();
}

class _PollRespondersPageState extends State<PollRespondersPage> {
  PollRespondersBloc _pollRespondersBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _pollRespondersBloc = widget.initPollRespondersBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _pollRespondersBloc.dispose();
    _subscriptions.forEach((s) => s.cancel());
    print('[DEBUG] PollRespondersPage#dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Poll Answers',
          ),
        ),
        backgroundColor: Colors.white,
        body: StreamBuilder<PollRespondersState>(
          stream: _pollRespondersBloc.pollRespondersState$,
          initialData: _pollRespondersBloc.pollRespondersState$.value,
          builder: (context, snapshot) {
            var data = snapshot.data;

            if (data.error != null) {
              print(data.error);
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

            return ListView.separated(
              shrinkWrap: true,
              physics: PageScrollPhysics(),
              itemCount: data.responders.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/profile',
                      arguments: data.responders[index].id,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        ImageHolder(
                          size: 50,
                          image: data.responders[index].image,
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.responders[index].name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    'Answered',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  data.responders[index].answer,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(color: Colors.grey[50]);
              },
            );
          },
        ));
  }
}
