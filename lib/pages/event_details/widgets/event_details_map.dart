import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;

class EventDetailsMap extends StatelessWidget {
  final LatLng location;

  const EventDetailsMap(this.location);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Event Map',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.directions,
            ),
            onPressed: () => openMapsSheet(context),
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId('location'),
            position: location,
          ),
        },
        initialCameraPosition: CameraPosition(
          zoom: 17,
          target: location,
        ),
      ),
    );
  }

  void openMapsSheet(context) async {
    try {
      final title = '';
      final description = '';
      final coords = launcher.Coords(location.latitude, location.longitude);
      final availableMaps = await launcher.MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords, 
                          title: title, 
                          description: description,
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30,
                          width: 30,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      );
    } catch (e) {
      print(e);
    }
  }
}