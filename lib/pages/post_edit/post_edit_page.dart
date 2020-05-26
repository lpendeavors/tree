import 'dart:async';

import 'package:flutter/material.dart';
import '../../widgets/image_holder.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './post_edit_bloc.dart';
import './post_edit_state.dart';

class EditPostPage extends StatefulWidget {
  final UserBloc userBloc;
  final EditPostBloc Function() initEditPostBloc;
  
  const EditPostPage({
    Key key,
    @required this.userBloc,
    @required this.initEditPostBloc,
  }) : super(key: key);
  
  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  EditPostBloc _editPostBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _editPostBloc = widget.initEditPostBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((event) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _editPostBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EditPostMessage message) {
    print('[DEBUG] EditPostMessage=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _editPostBloc.dispose();
    print('[DEBUG] _EditPostPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);

    return StreamBuilder<EditPostState>(
      stream: _editPostBloc.postEditState$,
      initialData: _editPostBloc.postEditState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        return WillPopScope(
          onWillPop: () async {
            // TODO: confirm exit
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              centerTitle: false,
              title: Text(
                'Share Something',
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
                      'POST',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      _editPostBloc.savePost();
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(),
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              child: Text('Show all options'),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ImageHolder(
                              size: 40,
                              image: '',
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Hi fullName Share Something?',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (data.postItem != null) ...[
                        if (data.postItem.tagged.isNotEmpty) ...[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                width: 0.5,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: Wrap(
                              spacing: 5,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              runAlignment: WrapAlignment.start,
                              children: List.generate(
                                data.postItem.tagged.length,
                                (index) {
                                  return Chip(
                                    avatar: ImageHolder(
                                      size: 30,
                                      image: '',
                                    ),
                                    label: Text(
                                      data.postItem.tagged[index],
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Divider(height: 25),
                          if (data.postItem.images.isNotEmpty) ...[
                            Container(
                              height: 350,
                              margin: EdgeInsets.only(
                                top: 15,
                                bottom: 10,
                              ),
                              child: PageView.builder(
                                controller: PageController(
                                  viewportFraction: 0.9,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: data.postItem.images.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      // TODO: preview if video
                                    },
                                    child: Stack(
                                      alignment: Alignment.topLeft,
                                      children: <Widget>[
                                        Container(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ],
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  color: Colors.white,
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () {
                          // TODO: pick media
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.camera_alt,
                                size: 15,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Photos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () async {
                          // TODO: pick media
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.videocam,
                                size: 15,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Videos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () {
                          // TODO add tags
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.group_add,
                                size: 15,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Tagging',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}