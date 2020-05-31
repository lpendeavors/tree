import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/pages/settings/profile/profile_settings_bloc.dart';
import 'package:treeapp/pages/settings/profile/profile_settings_state.dart';
import 'package:treeapp/user_bloc/user_bloc.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/widgets/curved_scaffold.dart';

class ProfileSettingsPage extends StatefulWidget {

  final int index;
  final ProfileSettingsBloc Function() initProfileSettingsBloc;

  const ProfileSettingsPage({
    Key key,
    this.index,
    this.initProfileSettingsBloc
  }) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>{

  ProfileSettingsBloc _profileSettingsBloc;

  @override
  void initState() {
    _profileSettingsBloc = widget.initProfileSettingsBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children: <Widget>[
        _personal(),
        _church(),
        _phone()
      ],
      index: widget.index,
    );
  }

  _buildAppBar(title) {
    return Padding(
      padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (Platform.isIOS)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _personal(){
    return CurvedScaffold(
      curveRadius: 25,
      appBar: _buildAppBar("Update Personal Information"),
      body: StreamBuilder(
        stream: _profileSettingsBloc.settingState$,
        initialData: _profileSettingsBloc.settingState$.value,
        builder: (context, data){
          ProfileSettingsState state = data.data;
          return Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(state.firstName),
                Text(state.lastName),
              ],
            ),
          );
        },
      ),
    );
  }

  _church(){
    return CurvedScaffold(
      curveRadius: 25,
      appBar: _buildAppBar("Update Church Information"),
      body: Container()
    );
  }

  _phone(){
    return CurvedScaffold(
      curveRadius: 25,
      appBar: _buildAppBar("Update Phone Information"),
      body: Container()
    );
  }

}