import 'dart:async';
import 'dart:io';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../util/asset_utils.dart';
import '../../util/event_utils.dart';
import '../../util/permission_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './event_edit_bloc.dart';
import './event_edit_state.dart';

class EventEditPage extends StatefulWidget {
  final UserBloc userBloc;
  final EventEditBloc Function() initEventEditBloc;
  final int eventType;

  const EventEditPage({
    Key key,
    @required this.userBloc,
    @required this.initEventEditBloc,
    this.eventType,
  }) : super(key: key);

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  EventEditBloc _eventEditBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _eventEditBloc = widget.initEventEditBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _eventEditBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EventEditedMessage message) {
    print('[DEBUG] EventEditedMessage=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _eventEditBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return StreamBuilder<EventEditState>(
      stream: _eventEditBloc.eventEditState$,
      initialData: _eventEditBloc.eventEditState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            centerTitle: false,
            elevation: 1,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Text(
              eventTypes[
                widget.eventType
              ].eventTitle,
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
                    data.eventDetails == null
                     ? s.event_create_title
                     : s.event_save_title,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _eventEditBloc.saveEvent,
                ),
              ),
            ],
          ),
          body: ListView(
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    StreamBuilder<List<String>>(
                      stream: _eventEditBloc.images$,
                      initialData: _eventEditBloc.images$.value,
                      builder: (context, snapshot) {
                        var newImages = snapshot.data;
                        if (newImages.isEmpty && data.eventDetails == null) {
                          return Container();
                        } else {
                          return Container(
                            height: 400,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            child: PageView.builder(
                              controller: PageController(
                                viewportFraction: 0.9
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: data.eventDetails != null
                                ? data.eventDetails.media.length
                                : newImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: 5,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: <Widget>[
                                      ClipRRect(
                                        child: AnimatedContainer(
                                          curve: Curves.ease,
                                          height: double.infinity,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          duration: Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: Color(0xff14000000),
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Card(
                                                elevation: 0.5,
                                                color: Colors.transparent,
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                    data.eventDetails == null
                                                      ? Image.file(
                                                          File(newImages[index]),
                                                        )
                                                      : Image(
                                                          height: double.infinity,
                                                          width: double.infinity,
                                                          fit: BoxFit.cover,
                                                          image: CacheImage(data.eventDetails.media[index].url),
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          var newList = newImages;
                                          newList.remove(newImages[index]);
                                          _eventEditBloc.imagesChanged(newList);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            top: 20,
                                          ),
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            child: Icon(
                                              Icons.clear,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                    RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
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
                            s.event_add_photos,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        bool hasPermission = await checkMediaPermission();
                        if (hasPermission) {
                          // Get image file
                          var file = await ImagePicker.pickImage(
                            source: ImageSource.gallery
                          );

                          // Allow cropping
                          var cropped = await ImageCropper.cropImage(
                            sourcePath: file.path,
                          );
                          
                          // Add to image list
                          var eventImages = _eventEditBloc.images$.value;
                          eventImages.add(cropped.path);

                          _eventEditBloc.imagesChanged(eventImages);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 12, 
                  right: 12
                ),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: data.eventDetails == null
                        ? ""
                        : data.eventDetails.title,
                      onChanged: _eventEditBloc.titleChanged,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                      decoration: InputDecoration(
                        hintText: s.event_title,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.timer,
                                color: Colors.black,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                data.eventDetails == null
                                ? s.event_start_end_date
                                : data.eventDetails.startDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    DatePicker.showDateTimePicker(
                                      context,
                                      showTitleActions: true,
                                      onConfirm: (selectedDate) {
                                        _eventEditBloc.startDateChanged(selectedDate);
                                        _eventEditBloc.startTimeChanged(selectedDate);
                                      }
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.centerLeft,
                                          child: StreamBuilder<DateTime>(
                                            stream: _eventEditBloc.startDate$,
                                            initialData: _eventEditBloc.startDate$.value,
                                            builder: (context, snapshot) {
                                              var date = data.eventDetails == null
                                                ? snapshot.data
                                                : data.eventDetails.startDate;
                                              
                                              return Text(
                                                date != null
                                                  ? DateFormat.yMMMMd().format(date)
                                                  : "Start date",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black.withOpacity(1),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          child: StreamBuilder<DateTime>(
                                            stream: _eventEditBloc.startTime$,
                                            initialData: _eventEditBloc.startTime$.value,
                                            builder: (context, snapshot) {
                                              var time = data.eventDetails == null
                                                  ? snapshot.data
                                                  : data.eventDetails.startTime;

                                              return Text(
                                                time != null 
                                                  ? DateFormat.jm().format(time)
                                                  : 'Start time',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black.withOpacity(1),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () async {
                                    DatePicker.showDateTimePicker(
                                      context,
                                      showTitleActions: true,
                                      onConfirm: (selectedDate) {
                                        _eventEditBloc.endDateChanged(selectedDate);
                                        _eventEditBloc.endTimeChanged(selectedDate);
                                      }
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.centerLeft,
                                          child: StreamBuilder<DateTime>(
                                            stream: _eventEditBloc.endDate$,
                                            initialData: _eventEditBloc.endDate$.value,
                                            builder: (context, snapshot) {
                                              var date = data.eventDetails == null
                                                ? snapshot.data
                                                : data.eventDetails.endDate;
                                              
                                              return Text(
                                                date != null
                                                  ? DateFormat.yMMMMd().format(date)
                                                  : "End date",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black.withOpacity(1),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          child: StreamBuilder<DateTime>(
                                            stream: _eventEditBloc.endTime$,
                                            initialData: _eventEditBloc.endTime$.value,
                                            builder: (context, snapshot) {
                                              var time = data.eventDetails == null
                                                  ? snapshot.data
                                                  : data.eventDetails.endTime;

                                              return Text(
                                                time != null 
                                                  ? DateFormat.jm().format(time)
                                                  : 'End time',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black.withOpacity(1),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.event_note,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.describe_event,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          TextFormField(
                            onChanged: _eventEditBloc.descriptionChanged,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: s.event_details_hint,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.link,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_destination_link,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          TextFormField(
                            onChanged: _eventEditBloc.webAddressChanged,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: s.event_web_address,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.attach_money,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_cost_label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          TextFormField(
                            onChanged: _eventEditBloc.costChanged,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.black26,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                s.event_venue_label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          ListTile(
                            onTap: () async {
                              LocationResult result = await showLocationPicker(
                                context, 
                                'AIzaSyBJp2E8-Vsc6x9MFkQqD2_oGBskyVfV8xQ'
                              );
                              
                              print(result.toString());
                            },
                            title: Text(
                              s.event_venue_hint,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container( 
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '🔥 Promote Your Event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: StreamBuilder<bool>(
                              stream: _eventEditBloc.isSponsored$,
                              initialData: _eventEditBloc.isSponsored$.value,
                              builder: (context, snapshot) {
                                var _isSponsored = data.eventDetails == null
                                  ? _eventEditBloc.isSponsored$.value
                                  : data.eventDetails.isSponsored;

                                return SwitchListTile(
                                  value: _isSponsored,
                                  activeColor: Colors.blue[900],
                                  title: Text(
                                    s.event_sponsored_hint,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  onChanged: _eventEditBloc.isSponsoredChanged,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          StreamBuilder<String>(
                            stream: _eventEditBloc.cost$,
                            initialData: _eventEditBloc.cost$.value,
                            builder: (context, snapshot) {
                              if ((snapshot.data ?? "").isEmpty) {
                                return Container();
                              } else {
                                return Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        s.event_estimate_label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'sponsor reach',
                                            style: TextStyle(
                                              fontSize: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Image.asset(friends, height: 25),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          StreamBuilder<bool>(
                            stream: _eventEditBloc.isSponsored$,
                            initialData: _eventEditBloc.isSponsored$.value,
                            builder: (context, snapshot) {
                              var _isSponsored = data.eventDetails == null
                                ? _eventEditBloc.isSponsored$.value
                                : data.eventDetails.isSponsored;

                              if (!_isSponsored) {
                                return Container();
                              } else {
                                return Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          s.event_budget_label,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _showBudgetMessageDialog();
                                          },
                                          child: Icon(
                                            Icons.help,
                                            size: 25,
                                            color: Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    StreamBuilder<String>(
                                      stream: _eventEditBloc.cost$,
                                      initialData: _eventEditBloc.cost$.value,
                                      builder: (context, snapshot) {
                                        var _cost = data.eventDetails == null
                                          ? _eventEditBloc.cost$.value
                                          : data.eventDetails.eventCost;
                                        
                                        return TextFormField(
                                          initialValue: _cost,
                                          onChanged: _eventEditBloc.budgetChanged,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey.withOpacity(0.2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBudgetMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(24),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  'Budget',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff8470ff),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'This is the amout you wish to spend in running this advertisement.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}