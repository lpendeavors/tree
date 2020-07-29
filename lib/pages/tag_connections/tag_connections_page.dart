import 'dart:async';

import 'package:flutter/material.dart';
import 'package:treeapp/generated/l10n.dart';
import 'package:treeapp/user_bloc/user_bloc.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import 'package:treeapp/widgets/image_holder.dart';
import './tag_connections_bloc.dart';
import './tag_connections_state.dart';

class TagConnectionsPage extends StatefulWidget {
  final UserBloc userBloc;
  final TagConnectionsBloc Function() initTagConnectionsBloc;

  const TagConnectionsPage({
    Key key,
    @required this.userBloc,
    @required this.initTagConnectionsBloc,
  }) : super(key: key);

  @override
  _TagConnectionsPageState createState() => _TagConnectionsPageState();
}

class _TagConnectionsPageState extends State<TagConnectionsPage> {
  TagConnectionsBloc _tagConnectionsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _tagConnectionsBloc = widget.initTagConnectionsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
    ];
  }

  @override
  void dispose() {
    _tagConnectionsBloc.dispose();
    _subscriptions.forEach((s) => s.cancel());
    print('[DEBUG] TagConnectionsPage#dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.grey,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        title: Text(
          'Tag Connections',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'DONE',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                var tagged = _tagConnectionsBloc.tagged$.value;
                Navigator.of(context).pop(tagged);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<ConnectionItem>>(
              stream: _tagConnectionsBloc.tagged$,
              initialData: _tagConnectionsBloc.tagged$.value,
              builder: (context, snapshot) {
                var tagged = snapshot.data;

                if (tagged.isEmpty) {
                  return Container();
                }

                return Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Wrap(
                    spacing: 5,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: List.generate(
                      tagged.length,
                      (index) {
                        return Chip(
                          avatar: ImageHolder(
                            size: 30,
                            image: tagged[index].image,
                          ),
                          label: Text(
                            tagged[index].name,
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          onDeleted: () {
                            var isTagged = tagged;
                            isTagged.remove(tagged[index]);
                            _tagConnectionsBloc.taggedChanged(isTagged);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Divider(
              height: 25,
            ),
            StreamBuilder<TagConnectionsState>(
              stream: _tagConnectionsBloc.tagConnectionsState$,
              initialData: _tagConnectionsBloc.tagConnectionsState$.value,
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
                    itemCount: data.connections.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          var tagged = _tagConnectionsBloc.tagged$.value;

                          if (tagged.contains(data.connections[index])) {
                            tagged.remove(data.connections[index]);
                            _tagConnectionsBloc.taggedChanged(tagged);
                          } else {
                            tagged.add(data.connections[index]);
                            _tagConnectionsBloc.taggedChanged(tagged);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Row(
                                  children: <Widget>[
                                    ImageHolder(
                                      size: 50,
                                      image: data.connections[index].image,
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            data.connections[index].name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            data.connections[index].about,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder<List<ConnectionItem>>(
                                stream: _tagConnectionsBloc.tagged$,
                                initialData: _tagConnectionsBloc.tagged$.value,
                                builder: (context, snapshot) {
                                  var tagged = snapshot.data;
                                  var active =
                                      tagged.contains(data.connections[index]);

                                  return Container(
                                    height: 25,
                                    width: 25,
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    decoration: active
                                        ? BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0XFFe46514),
                                                Color(0XFFf79836),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          )
                                        : BoxDecoration(
                                            color: Colors.grey[100],
                                            border:
                                                Border.all(color: Colors.grey),
                                            shape: BoxShape.circle,
                                          ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey[50],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
