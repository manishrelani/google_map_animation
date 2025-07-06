import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_animation/google_map_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'data.dart';

void main() async {
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  try {
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      WidgetsFlutterBinding.ensureInitialized();
      await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.legacy);
    }
  } catch (e) {
    debugPrint('Error initializing Google Maps: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? mapController;
  MapAnimationController? mapAnimationController;

  Timer? _timer;

  final cordinatesList = [
    ListCycler(coordinates1),
    ListCycler(coordinates2),
    ListCycler(coordinates3),
    ListCycler(coordinates1.reversed.toList()),
    ListCycler(coordinates2.reversed.toList()),
    ListCycler(coordinates3.reversed.toList()),
  ];

  late final Map<MarkerId, Marker> _markers = {
    const MarkerId('0'): Marker(
      markerId: const MarkerId('0'),
      position: cordinatesList[0].currentValue,
      rotation: 0,
    ),
    const MarkerId('1'): Marker(
      markerId: const MarkerId('1'),
      position: cordinatesList[1].currentValue,
      rotation: 90,
    ),
    const MarkerId('2'): Marker(
      markerId: const MarkerId('2'),
      position: cordinatesList[2].currentValue,
      rotation: 180,
    ),
    const MarkerId('3'): Marker(
      markerId: const MarkerId('3'),
      position: cordinatesList[3].currentValue,
      rotation: 270,
    ),
    const MarkerId('4'): Marker(
      markerId: const MarkerId('4'),
      position: cordinatesList[4].currentValue,
      rotation: 0,
    ),
    const MarkerId('5'): Marker(
      markerId: const MarkerId('5'),
      position: cordinatesList[5].currentValue,
      rotation: 90,
    ),
  };

  final Set<AnimatedPolyline> _polylines = {
    AnimatedPolyline(
      polyline: Polyline(
        polylineId: PolylineId('front'),
        color: Colors.black,
        width: 2,
        points: MapAnimationUtils.generateEquidistantPolylineByDuration(
          path: coordinates1,
          duration: const Duration(seconds: 4),
        ),
      ),
      polylineAnimator: FadeInProgressiveAnimator(
        repeat: true,
        curve: Curves.linear,
        duration: const Duration(seconds: 4),
        delayStart: const Duration(seconds: 1),
      ),
    ),
    AnimatedPolyline(
      polyline: Polyline(
        polylineId: PolylineId('back'),
        color: Colors.grey,
        width: 2,
        points: coordinates1,
      ),
    ),
  };

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      for (var i = 0; i < cordinatesList.length; i++) {
        _markers.update(
          MarkerId('${i + 1}'),
          (marker) => marker.copyWith(positionParam: cordinatesList[i].nextValue),
        );
      }

      mapAnimationController?.updateMarkers(_markers.values.toSet());
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map Screen',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(23.02246, 72.59891), zoom: 16.0),
        onMapCreated: (controller) {
          mapController = controller;
          mapAnimationController = MapAnimationController(
            mapId: controller.mapId,
            vsync: this,
            polylines: _polylines,
          );
        },
      ),
    );
  }
}

class ListCycler<E> {
  final List<E> list;
  int _currentIndex = 0;

  bool _isReversed = false;

  ListCycler(this.list);

  E get nextValue {
    if (_currentIndex == list.length - 1) {
      _isReversed = true;
    } else if (_currentIndex == 0) {
      _isReversed = false;
    }

    if (_isReversed) {
      _currentIndex--;
    } else {
      _currentIndex++;
    }

    return list[_currentIndex];
  }

  E get currentValue => list[_currentIndex];
}
