import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../generated/l10n.dart';
import '../../widgets/image_holder.dart';
import '../../util/permission_utils.dart';
import './create_group_bloc.dart';
import './create_group_state.dart';

class CreateGroupPage extends StatefulWidget {
  final UserBloc userBloc;
  final CreateGroupBloc Function() initCreateGroupBloc;

  const CreateGroupPage({
    Key key,
    @required this.userBloc,
    @required this.initCreateGroupBloc,
  }) : super(key: key);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  CreateGroupBloc _groupBloc;
  List<StreamSubscription> _subscriptions;

  var _groupNameController = TextEditingController();
  var _groupDescriptionController = TextEditingController();
  var _editLoaded = false;
  var _mediaChanged = false;

  @override
  void initState() {
    super.initState();

    _groupBloc = widget.initCreateGroupBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _groupBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(GroupCreateMessage message) {
    if (message is GroupCreateSuccess) {
      Navigator.of(context).pushReplacementNamed(
        '/chat_room',
        arguments: message.details,
      );
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _groupBloc.dispose();
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    print('[DEBUG] _CreateGroupPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GroupCreateState>(
        stream: _groupBloc.groupCreateState$,
        initialData: _groupBloc.groupCreateState$.value,
        builder: (context, snapshot) {
          var existingGroup = snapshot.data;

          if (existingGroup.groupItem != null && !_editLoaded) {
            _updateFields(existingGroup.groupItem);
            _editLoaded = true;
          }

          return WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: false,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                title: Text(
                  existingGroup.groupItem != null
                      ? 'Edit Group'
                      : 'Create Group',
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
                      child: StreamBuilder<bool>(
                          stream: _groupBloc.isLoading$,
                          initialData: _groupBloc.isLoading$.value,
                          builder: (context, snapshot) {
                            var loading = snapshot.data ?? false;

                            if (loading) {
                              return CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              );
                            }

                            return Text(
                              existingGroup.groupItem != null ? 'SAVE' : 'POST',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            );
                          }),
                      onPressed: () => _groupBloc.saveGroup(),
                    ),
                  ),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      bool hasPermission = await checkMediaPermission();
                      if (hasPermission) {
                        var file = await ImagePicker().getImage(
                          source: ImageSource.gallery,
                        );
                        var cropped = await ImageCropper.cropImage(
                          sourcePath: file.path,
                        );
                        _groupBloc.groupImageChanged(cropped.path);
                        _groupBloc.mediaUpdated(true);
                        setState(() => _mediaChanged = true);
                      }
                    },
                    child: StreamBuilder<String>(
                      stream: _groupBloc.groupImage$,
                      initialData: _groupBloc.groupImage$.value,
                      builder: (context, snapshot) {
                        var image = snapshot.data ?? "";

                        print('image=$image');

                        if (image.isEmpty) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            color: Colors.black.withOpacity(0.06),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add_a_photo,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Group Photo',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (_editLoaded && !_mediaChanged)
                                  ? NetworkImage(image)
                                  : FileImage(File(image)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          maxLength: 50,
                          controller: _groupNameController,
                          onChanged: _groupBloc.groupNameChanged,
                          style: TextStyle(
                            fontSize: 22,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Group Name',
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          maxLength: 400,
                          maxLines: 5,
                          controller: _groupDescriptionController,
                          onChanged: _groupBloc.groupDescriptionChanged,
                          decoration: InputDecoration(
                            hintText: 'Group Description',
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        StreamBuilder<bool>(
                          stream: _groupBloc.groupPrivate$,
                          initialData: _groupBloc.groupPrivate$.value,
                          builder: (context, snapshot) {
                            var private = snapshot.data ?? false;
                            return SwitchListTile.adaptive(
                              title: Text(
                                'Change the visibility of the group to ${private ? 'public' : 'private'}',
                              ),
                              value: private,
                              onChanged: _groupBloc.groupIsPrivateChanged,
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Container(
                          color: Colors.blue,
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.info,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: StreamBuilder(
                                  stream: _groupBloc.groupPrivate$,
                                  initialData: _groupBloc.groupPrivate$.value,
                                  builder: (context, snapshot) {
                                    var private = snapshot.data ?? false;
                                    return Text(
                                      'This group is ${private ? 'hidden' : 'visible'}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(8),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 0.5,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: StreamBuilder<List<MemberItem>>(
                      stream: _groupBloc.groupMembers$,
                      initialData: _groupBloc.groupMembers$.value,
                      builder: (context, snapshot) {
                        var members = snapshot.data ?? [];
                        return Wrap(
                          spacing: 5,
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: List.generate(
                            members.length,
                            (index) {
                              return Chip(
                                avatar: ImageHolder(
                                  size: 30,
                                  image: members[index].image,
                                ),
                                label: Text(
                                  members[index].name,
                                  style: TextStyle(
                                    fontSize: 10,
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
            ),
          );
        });
  }

  void _updateFields(GroupItem group) {
    _groupBloc.groupNameChanged(group.name);
    _groupNameController.text = group.name;

    _groupBloc.groupIsPrivateChanged(group.isPublic);

    _groupBloc.groupDescriptionChanged(group.description);
    _groupDescriptionController.text = group.description;

    _groupBloc.groupImageChanged(group.image);
  }
}
