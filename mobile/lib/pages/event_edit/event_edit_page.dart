import 'dart:async';
import 'dart:io';

// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
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
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _eventEditBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EventEditedMessage message) async {
    print('[DEBUG] EventEditedMessage=$message');
    if (message is EventEditedMessageSuccess) {
      await _showApprovalAlert();
      Navigator.of(context).pop();
    }
  }

  Future<void> _showApprovalAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pending approval'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will be notified if your event is approved'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        var existingEvent = snapshot.data;

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
              eventTypes[widget.eventType].eventTitle,
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
                      stream: _eventEditBloc.isLoading$,
                      initialData: _eventEditBloc.isLoading$.value,
                      builder: (context, snapshot) {
                        bool loading = snapshot.data ?? false;

                        if (loading) {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                          );
                        }

                        return Text(
                          existingEvent.eventDetails == null
                              ? s.event_create_title
                              : s.event_save_title,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        );
                      }),
                  onPressed: () {
                    var startDate = _eventEditBloc.startDate$.value;
                    var endDate = _eventEditBloc.endDate$.value;
                    if ((startDate is DateTime &&
                            startDate.isAfter(DateTime.now())) ||
                        (endDate is DateTime &&
                            endDate.isAfter(DateTime.now()))) {
                      _eventEditBloc.saveEvent();
                    } else {
                      return showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Invalid Event Date'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('Please select a future date.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
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
                        if (newImages.isEmpty &&
                            existingEvent.eventDetails == null) {
                          return Container();
                        } else {
                          return Container(
                            height: 400,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.9),
                              scrollDirection: Axis.horizontal,
                              itemCount: existingEvent.eventDetails != null
                                  ? existingEvent.eventDetails.media.length
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
                                                  borderRadius:
                                                      BorderRadius.circular(5),
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
                                                    existingEvent
                                                                .eventDetails ==
                                                            null
                                                        ? Image.file(
                                                            File(newImages[
                                                                index]),
                                                          )
                                                        : CachedNetworkImage(
                                                            height:
                                                                double.infinity,
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                existingEvent
                                                                    .eventDetails
                                                                    .media[
                                                                        index]
                                                                    .url,
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
                              source: ImageSource.gallery);

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
                    StreamBuilder<EventImageError>(
                      stream: _eventEditBloc.imageError$,
                      initialData: null,
                      builder: (context, snapshot) {
                        var error = snapshot.data ?? null;

                        if (error is EventImageError) {
                          return Align(
                            alignment: Alignment.center,
                            child: Text(
                              'A photo is required',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          );
                        }

                        return Container();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: existingEvent.eventDetails != null
                          ? existingEvent.eventDetails.title
                          : '',
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
                    StreamBuilder<EventTitleError>(
                      stream: _eventEditBloc.titleError$,
                      initialData: null,
                      builder: (context, snapshot) {
                        var error = snapshot.data ?? null;

                        if (error is EventTitleError) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'A valid title is required.',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          );
                        }

                        return Container();
                      },
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
                                s.event_start_end_date,
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
                                StreamBuilder<DateTime>(
                                  initialData: _eventEditBloc.startDate$.value,
                                  builder: (context, snapshot) {
                                    DateTime existingDate =
                                        snapshot.data ?? DateTime.now();

                                    return DateTimeField(
                                      format: DateFormat(
                                          "MMMM dd, yyyy 'at' h:mma"),
                                      initialValue: existingDate,
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            initialDate: existingDate,
                                            lastDate: DateTime(2100));
                                        if (date != null) {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                existingDate),
                                          );
                                          _eventEditBloc.startDateChanged(
                                              DateTimeField.combine(
                                                  date, time));
                                          _eventEditBloc.startTimeChanged(
                                              DateTimeField.combine(
                                                  date, time));
                                          return DateTimeField.combine(
                                              date, time);
                                        } else {
                                          return currentValue;
                                        }
                                      },
                                    );
                                  },
                                ),
                                StreamBuilder<EventStartDateError>(
                                  stream: _eventEditBloc.startDateError$,
                                  initialData: null,
                                  builder: (context, snapshot) {
                                    var error = snapshot.data ?? null;

                                    if (error is EventStartDateError) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'A valid start date is required.',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    }

                                    return Container();
                                  },
                                ),
                                SizedBox(height: 10),
                                StreamBuilder<DateTime>(
                                  initialData: _eventEditBloc.endDate$.value,
                                  builder: (context, snapshot) {
                                    DateTime existingDate =
                                        snapshot.data ?? DateTime.now();

                                    return DateTimeField(
                                      format: DateFormat(
                                          "MMMM dd, yyyy 'at' h:mma"),
                                      initialValue: existingDate,
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            initialDate:
                                                currentValue ?? existingDate,
                                            lastDate: DateTime(2100));
                                        if (date != null) {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                existingDate),
                                          );
                                          _eventEditBloc.endDateChanged(
                                              DateTimeField.combine(
                                                  date, time));
                                          _eventEditBloc.endTimeChanged(
                                              DateTimeField.combine(
                                                  date, time));
                                          return DateTimeField.combine(
                                              date, time);
                                        } else {
                                          return currentValue;
                                        }
                                      },
                                    );
                                  },
                                ),
                                StreamBuilder<EventEndDateError>(
                                  stream: _eventEditBloc.endDateError$,
                                  initialData: null,
                                  builder: (context, snapshot) {
                                    var error = snapshot.data ?? null;

                                    if (error is EventEndDateError) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'A valid end date is required.',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    }

                                    return Container();
                                  },
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
                            initialValue: existingEvent.eventDetails != null
                                ? existingEvent.eventDetails.description
                                : '',
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
                          StreamBuilder<EventDescriptionError>(
                            stream: _eventEditBloc.descriptionError$,
                            initialData: null,
                            builder: (context, snapshot) {
                              var error = snapshot.data ?? null;

                              if (error is EventDescriptionError) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'A valid description is required.',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              return Container();
                            },
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
                            initialValue: existingEvent.eventDetails != null
                                ? existingEvent.eventDetails.webAddress
                                : '',
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
                            initialValue: existingEvent.eventDetails != null
                                ? existingEvent.eventDetails.eventCost
                                    .toStringAsFixed(2)
                                : '',
                            onChanged: _eventEditBloc.costChanged,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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
                          StreamBuilder(
                            stream: _eventEditBloc.geoLoading$,
                            initialData: _eventEditBloc.geoLoading$.value,
                            builder: (context, snapshot) {
                              var loading = snapshot.data;

                              if (loading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return ListTile(
                                onTap: () async {
                                  _eventEditBloc.geoLoadingChanged(true);

                                  Position location =
                                      await Geolocator().getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high,
                                  );

                                  LocationResult result =
                                      await showLocationPicker(
                                    context,
                                    'AIzaSyBJp2E8-Vsc6x9MFkQqD2_oGBskyVfV8xQ',
                                    initialCenter: LatLng(
                                        location.latitude, location.longitude),
                                  );

                                  _eventEditBloc.geoLoadingChanged(false);

                                  if (result != null) {
                                    _eventEditBloc.venueChanged(result.address);
                                    _eventEditBloc.venueGeoChanged(
                                      Tuple2(
                                        result.latLng.latitude,
                                        result.latLng.longitude,
                                      ),
                                    );
                                  }
                                },
                                title: StreamBuilder<String>(
                                    stream: _eventEditBloc.venue$,
                                    initialData: _eventEditBloc.venue$.value,
                                    builder: (context, snapshot) {
                                      var venue = snapshot.data ?? "";
                                      return Text(
                                        _eventEditBloc.eventEditState$.value
                                                    .eventDetails ==
                                                null
                                            ? venue.isEmpty
                                                ? s.event_venue_hint
                                                : venue
                                            : _eventEditBloc.eventEditState$
                                                .value.eventDetails.venue,
                                        style: TextStyle(
                                          color: venue.isEmpty
                                              ? Colors.grey
                                              : null,
                                          fontSize: 16,
                                        ),
                                      );
                                    }),
                              );
                            },
                          ),
                          StreamBuilder<EventVenueError>(
                            stream: _eventEditBloc.venueError$,
                            initialData: null,
                            builder: (context, snapshot) {
                              var error = snapshot.data ?? null;

                              if (error is EventVenueError) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'A valid location is required',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              return Container();
                            },
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
                                var _isSponsored = existingEvent.eventDetails ==
                                        null
                                    ? _eventEditBloc.isSponsored$.value
                                    : existingEvent.eventDetails.isSponsored;

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
                          // StreamBuilder<String>(
                          //   stream: _eventEditBloc.budget$,
                          //   initialData: _eventEditBloc.budget$.value,
                          //   builder: (context, snapshot) {
                          //     if ((snapshot.data ?? "").isEmpty) {
                          //       return Container();
                          //     } else {
                          //       return Container(
                          //         padding: EdgeInsets.all(8),
                          //         decoration: BoxDecoration(
                          //           color: Colors.blue.withOpacity(0.1),
                          //           borderRadius: BorderRadius.circular(10),
                          //         ),
                          //         child: Column(
                          //           children: <Widget>[
                          //             Text(
                          //               s.event_estimate_label,
                          //               style: TextStyle(
                          //                 fontSize: 12,
                          //                 color: Colors.black.withOpacity(0.7),
                          //               ),
                          //             ),
                          //             SizedBox(height: 10),
                          //             Row(
                          //               children: <Widget>[
                          //                 Text(
                          //                   'sponsor reach',
                          //                   style: TextStyle(
                          //                     fontSize: 30,
                          //                     color: Colors.blue,
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 10),
                          //                 Image.asset(friends, height: 25),
                          //               ],
                          //             ),
                          //           ],
                          //         ),
                          //       );
                          //     }
                          //   },
                          // ),
                          StreamBuilder<bool>(
                            stream: _eventEditBloc.isSponsored$,
                            initialData: _eventEditBloc.isSponsored$.value,
                            builder: (context, snapshot) {
                              var _isSponsored =
                                  existingEvent.eventDetails == null
                                      ? _eventEditBloc.isSponsored$.value
                                      : existingEvent.eventDetails.isSponsored;

                              if (!_isSponsored) {
                                return Container();
                              } else {
                                return Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    StreamBuilder<String>(
                                      stream: _eventEditBloc.budget$,
                                      initialData: _eventEditBloc.budget$.value,
                                      builder: (context, snapshot) {
                                        var _cost =
                                            existingEvent.eventDetails == null
                                                ? _eventEditBloc.budget$.value
                                                : existingEvent
                                                    .eventDetails.budget
                                                    .toStringAsFixed(2);

                                        return TextFormField(
                                          initialValue: _cost,
                                          onChanged:
                                              _eventEditBloc.budgetChanged,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
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
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
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

  void _updateBloc(EventEditState state) {
    if (state.eventDetails != null) {
      var event = state.eventDetails;
      _eventEditBloc.titleChanged(event.title);
      _eventEditBloc.descriptionChanged(event.description);
      // _eventEditBloc.imagesChanged(event.media.map((m) => m.url).toList());
      _eventEditBloc.startDateChanged(event.startDate);
      _eventEditBloc.startTimeChanged(event.startTime);
      _eventEditBloc.endDateChanged(event.endDate);
      _eventEditBloc.endTimeChanged(event.endTime);
      _eventEditBloc.webAddressChanged(event.webAddress);
      _eventEditBloc.costChanged(event.eventCost.toStringAsFixed(2));
      _eventEditBloc.venueChanged(event.venue);
      _eventEditBloc.isSponsoredChanged(event.isSponsored);
      _eventEditBloc.budgetChanged(event.budget.toStringAsFixed(2));
    }
  }
}
