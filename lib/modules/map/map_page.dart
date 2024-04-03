import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  LatLng? location;
  GoogleMapController? mapController;
  StreamSubscription? positionStream;
  LocationPermission? permission;

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }

  void getUserLocation() async {
    LocationSettings locationSettings;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      location = LatLng(position.latitude, position.longitude);

      setState(() {});
    });

    permission = await Geolocator.requestPermission();
    if (GetPlatform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: true,
      );
    } else if (GetPlatform.isIOS || GetPlatform.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      location = LatLng(position!.latitude, position.longitude);
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.0,
          ),
        ),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            markers: {
              Marker(
                  markerId: const MarkerId('Live Location'),
                  position: location ?? const LatLng(0, 0))
            },
            initialCameraPosition:
                const CameraPosition(target: LatLng(0.0, 0.0)),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
        ),
      ),
    );
  }
}
