import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treeapp/pages/connections/widgets/connection_list_item.dart';
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

class _ConnectionsPageState extends State<ConnectionsPage> {
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
          builder: (context, snapshot) {
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

            return ListView.builder(
              itemCount: data.connectionItems.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return ConnectionListItem(user: data.connectionItems[index]);
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
}
