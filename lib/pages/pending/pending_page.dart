import 'dart:async';

import 'package:flutter/material.dart';
import 'package:treeapp/generated/l10n.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/widgets/empty_list_view.dart';
import 'package:treeapp/widgets/image_holder.dart';
import './pending_state.dart';
import './pending_bloc.dart';

class PendingPage extends StatefulWidget {
  final PendingBloc pendingBloc;

  const PendingPage({
    Key key,
    @required this.pendingBloc,
  }) : super(key: key);

  _PendingPageState createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  PendingBloc _pendingBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _pendingBloc = widget.pendingBloc;
    _subscriptions = [
      _pendingBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(PendingApprovalMessage message) {
    print('[DEBUG] PendingApprovalMessage=$message');
  }

  @override
  void dispose() {
    print('[DEBUG] _PendingState#dispose');
    _pendingBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Pending Approval',
          style: TextStyle(
            fontSize: 17,
            color: Color(0xffff0000),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: StreamBuilder<PendingState>(
              stream: _pendingBloc.pendingState$,
              initialData: _pendingBloc.pendingState$.value,
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

                if (data.pending.isEmpty) {
                  return EmptyListView(
                    title: 'Nothing Pending Yet',
                    description: '',
                    icon: Icons.report,
                  );
                }

                return Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.pending.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/profile',
                            arguments: data.pending[index].id,
                          );
                        },
                        child: AbsorbPointer(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ImageHolder(
                                  size: 60,
                                  image: data.pending[index].image,
                                ),
                                SizedBox(width: 15),
                                Flexible(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                  '/profile',
                                                  arguments:
                                                      data.pending[index].id,
                                                );
                                              },
                                              child: Text(
                                                data.pending[index].name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            if (data.pending[index].isChurch)
                                              Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    church_icon,
                                                    height: 10,
                                                    width: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Denomination',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                data.pending[index]
                                                    .denomination,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        if (!data.pending[index].isChurch) ...[
                                          SizedBox(height: 5),
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Image.asset(
                                                  church_icon,
                                                  height: 12,
                                                  width: 12,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  data.pending[index]
                                                      .churchName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  data.pending[index].isChurch
                                                      ? data.pending[index]
                                                          .churchAddress
                                                      : data
                                                          .pending[index].city,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Flexible(
                                              child: RaisedButton(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                onPressed: () {
                                                  _pendingBloc
                                                      .approveUser(true);
                                                  _pendingBloc.completeApproval(
                                                    data.pending[index].id,
                                                  );
                                                },
                                                child: Center(
                                                  child: Text(
                                                    'Approve',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                onPressed: () {
                                                  _pendingBloc
                                                      .approveUser(false);
                                                  _pendingBloc.completeApproval(
                                                    data.pending[index].id,
                                                  );
                                                },
                                                child: Center(
                                                  child: Text(
                                                    'Reject',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
