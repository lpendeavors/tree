import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../generated/l10n.dart';
import '../../../util/event_utils.dart';
import '../events_state.dart';
import '../events_bloc.dart';

class EventsMap extends StatefulWidget {
  final EventsBloc bloc;

  const EventsMap({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  _EventsMapState createState() => _EventsMapState();
}

class _EventsMapState extends State<EventsMap>
    with AutomaticKeepAliveClientMixin {
  var _kGooglePlex = CameraPosition(
    target: LatLng(
      37.42796133580664,
      -122.085749655962,
    ),
    zoom: 14,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationButtonEnabled: false,
          onMapCreated: (GoogleMapController controller) async {
            controller.setMapStyle(
              await rootBundle.loadString('assets/mapStyle.json'),
            );
          },
        ),
        IgnorePointer(
          child: Container(
            color: Colors.black.withOpacity(.0),
          ),
        ),
        StreamBuilder<EventsListState>(
          stream: widget.bloc.eventsListState$,
          initialData: widget.bloc.eventsListState$.value,
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

            return Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ...List.generate(eventTypes.length, (index) {
                          return IgnorePointer(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 30,
                                  width: 30,
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                    eventTypes[index].assetImage,
                                    height: 15,
                                    width: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  eventTypes[index].eventTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () {
                            bool isHidden = widget.bloc.hideEventsOnMap$.value;
                            widget.bloc.hideEventsOnMapChanged(!isHidden);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            margin: EdgeInsets.only(
                              right: 12,
                              top: 10,
                            ),
                            child: StreamBuilder<bool>(
                                stream: widget.bloc.hideEventsOnMap$,
                                initialData: widget.bloc.hideEventsOnMap$.value,
                                builder: (context, snapshot) {
                                  bool isHidden = snapshot.data ?? false;
                                  return Icon(
                                    isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  );
                                }),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<bool>(
                  stream: widget.bloc.hideEventsOnMap$,
                  initialData: widget.bloc.hideEventsOnMap$.value,
                  builder: (context, snapshot) {
                    bool hidden = snapshot.data ?? false;

                    if (hidden) {
                      return Container();
                    }

                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        child: Container(
                          height: 200,
                          margin: EdgeInsets.only(bottom: 10),
                          child: PageView.builder(
                            itemCount: data.eventItems.length,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (int) => {},
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/event_details',
                                    arguments: data.eventItems[index].id,
                                  );
                                },
                                onLongPress: () {
                                  // TODO: admin functionality
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          child: Stack(
                                            children: <Widget>[
                                              CachedNetworkImage(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                alignment: Alignment.center,
                                                fit: BoxFit.cover,
                                                imageUrl: data
                                                    .eventItems[index].image,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black
                                                          .withOpacity(0.1),
                                                      Colors.black
                                                          .withOpacity(0.9),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Flexible(
                                                        child: Text(
                                                          data.eventItems[index]
                                                              .location,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 25,
                                                        width: 25,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Image.asset(
                                                          eventTypes[data
                                                                  .eventItems[
                                                                      index]
                                                                  .eventType]
                                                              .assetImage,
                                                          height: 15,
                                                          width: 15,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // if (data.eventItems[index].isSponsored) ...[
                                              //   Align(
                                              //     alignment: Alignment.topCenter,
                                              //     child: Padding(
                                              //       padding: const EdgeInsets.all(8),
                                              //       child: Container(
                                              //         padding: EdgeInsets.all(4),
                                              //         decoration: BoxDecoration(
                                              //           color: Color(0xffe8e8e8).withOpacity(0.5),
                                              //           borderRadius: BorderRadius.circular(12),
                                              //         ),
                                              //         child: Text(
                                              //           '🔥 Sponsored Event',
                                              //           style: TextStyle(
                                              //             fontSize: 12,
                                              //             color: Colors.black,
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ],
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                height: 40,
                                                width: 40,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Color(0xffe8e8e8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      DateFormat.MMM().format(
                                                          data.eventItems[index]
                                                              .startDate),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat.d().format(data
                                                          .eventItems[index]
                                                          .startDate),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      '${DateFormat.jm().format(data.eventItems[index].startDate)}'
                                                      ' ${data.eventItems[index].title}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      data.eventItems[index]
                                                          .details,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black
                                                            .withOpacity(0.7),
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
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
