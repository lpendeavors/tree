import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../explore_state.dart';
import '../explore_bloc.dart';
import './connections_list_item.dart';

class ExploreConnectionsTab extends StatelessWidget {
  final ExploreBloc bloc;

  const ExploreConnectionsTab({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<ExploreState>(
        stream: bloc.exploreState$,
        initialData: bloc.exploreState$.value,
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

          if (data.connectionItems.isEmpty) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 150,
              child: Center(
                child: EmptyListView(
                  title: S.of(context).connections_empty_title,
                  description: S.of(context).connections_empty_desc,
                  icon: Icons.people,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (data.requestItems.isNotEmpty) ...[
                  Container(
                    color: Colors.grey[50],
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[50],
                    margin: EdgeInsets.only(
                      right: 5,
                      left: 5,
                    ),
                  ),
                  ListView.separated(
                    itemCount: data.connectionItems.length,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ConnectionListItem(
                        isRequest: true,
                        connectionItem: data.requestItems[index],
                        onRemove: (connection) => print('remove ${connection.name}'),
                        onConnect: (connection) => print('connect with ${connection.name}'),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 0.5,
                          width: MediaQuery.of(context).size.width,
                          child: Divider(),
                        ),
                      );
                    },
                  ),
                ],
                Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Suggestions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey[50],
                  margin: EdgeInsets.only(
                    right: 5,
                    left: 5,
                  ),
                ),
                ListView.separated(
                  itemCount: data.connectionItems.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ConnectionListItem(
                      isRequest: false,
                      connectionItem: data.connectionItems[index],
                      onRemove: (connection) => print('remove ${connection.name}'),
                      onConnect: (connection) => print('connect with ${connection.name}'),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width,
                        child: Divider(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}