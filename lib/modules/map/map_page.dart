import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    setCustomPinIcon();
    getUserLocation();
    super.initState();
  }

  void setCustomPinIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/icons/motorExcMark.png')
        .then(
      (value) => setState(
        () {
          markerIcon = value;
        },
      ),
    );
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
            zoom: 13.99,
          ),
        ),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              markers: {
                Marker(
                  markerId: const MarkerId('Current User'),
                  position: location ?? const LatLng(0, 0),
                  icon: markerIcon,
                ),
              },
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            Positioned(
              top: 25,
              left: 10,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.amber,
                ),
                child: const Center(
                    child: Icon(
                  Icons.chevron_left,
                  size: 40,
                )),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 130,
              child: GestureDetector(
                  onTap: () => Geolocator.getCurrentPosition(),
                  child: const Icon(Icons.my_location)),
            )
          ],
        ),
      ),
    );
  }
}
