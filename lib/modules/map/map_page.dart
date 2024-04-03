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
  BitmapDescriptor usermarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor otherusersmarkerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    setCurrentUserIcon();
    setOtherUsersIcon();
    getUserLocation();
    super.initState();
  }

  void setCurrentUserIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/icons/motorExcMark.png')
        .then(
      (value) => setState(
        () {
          usermarkerIcon = value;
        },
      ),
    );
  }

  void setOtherUsersIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/icons/motorLocMark.png')
        .then(
      (value) => setState(
        () {
          otherusersmarkerIcon = value;
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
            zoom: 12.0,
          ),
        ),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> otherUsers = [
      Marker(
        markerId: const MarkerId('User 2'),
        position: const LatLng(-6.174369315176477, 106.82548239827156),
        icon: otherusersmarkerIcon,
      ),
      Marker(
        markerId: const MarkerId('User 3'),
        position: const LatLng(-6.2339719110827465, 106.7985151335597),
        icon: otherusersmarkerIcon,
      ),
      Marker(
        markerId: const MarkerId('User 4'),
        position: const LatLng(-6.173853318151117, 106.79092146456242),
        icon: otherusersmarkerIcon,
      ),
    ];
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
                  icon: usermarkerIcon,
                ),
                ...otherUsers
              },
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                for (var element in otherUsers) {
                  double distanceInMeters = Geolocator.distanceBetween(
                      location!.latitude,
                      location!.longitude,
                      element.position.latitude,
                      element.position.longitude);
                  debugPrint(
                      'Jarak dengan ${element.markerId.value}: ${distanceInMeters.round() / 1000} km');
                }
              },
              circles: {
                Circle(
                    circleId: const CircleId('area'),
                    center: location ?? const LatLng(0, 0),
                    radius: 4000,
                    fillColor: Colors.black.withOpacity(0.3),
                    strokeWidth: 1,
                    strokeColor: Colors.black),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
