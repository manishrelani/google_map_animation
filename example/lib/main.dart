import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_map_animation/google_map_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  int _markerCounter = 1;

  Timer? _timer;

  final Map<MarkerId, Marker> _markers = {};

  final Set<AnimatedPolyline> _polylines = {
    AnimatedPolyline(
      polyline: Polyline(
        polylineId: PolylineId('1'),
        color: Colors.black,
        width: 2,
        points: MapAnimationUtils.generateEquidistantPolylineByDuration(
          path: snackPolyline,
          duration: const Duration(seconds: 3),
        ),
      ),
      polylineAnimator: FadeInProgressiveAnimator(
        repeat: true,
        curve: Curves.linear,
        duration: const Duration(seconds: 6),
      ),
    ),
    AnimatedPolyline(
      polyline: Polyline(polylineId: const PolylineId('2'), color: Colors.red, width: 2, points: colorPolyline),
      polylineAnimator: ColorTransitionAnimation(
        duration: const Duration(seconds: 10),
        repeat: true,
        colors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
      ),
    ),
  };

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _markers.updateAll((markerId, marker) {
        return marker.copyWith(
          positionParam: generateRandomLatLngInRadius(marker.position, 1000),
          rotationParam: Random().nextInt(360).toDouble(),
        );
      });
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
        title: const Text('Map Screen', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(12.97167, 77.59475), zoom: 16.0),

        onMapCreated: (controller) {
          mapController = controller;
          mapAnimationController = MapAnimationController(mapId: controller.mapId, vsync: this, polylines: _polylines);
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addMarker,
            tooltip: 'Add Marker',
            child: const Icon(Icons.add_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: _removeMarker,
            tooltip: 'Remove Marker',
            child: const Icon(Icons.remove_circle),
          ),

          FloatingActionButton(
            heroTag: 'add_polyline',
            onPressed: onAddPolyline,
            tooltip: 'Add Polyline',
            child: const Icon(Icons.add_road),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'remove_polyline',
            onPressed: onRemovePolyline,
            tooltip: 'Remove Polyline',
            child: const Icon(Icons.remove_road),
          ),
        ],
      ),
    );
  }

  void _addMarker() {
    final markerId = MarkerId(_markerCounter.toString());
    final position = generateRandomLatLngInRadius(const LatLng(12.97167, 77.59475), 1000);
    final marker = Marker(markerId: markerId, position: position, rotation: Random().nextInt(360).toDouble());
    _markers[markerId] = marker;

    mapAnimationController?.updateMarkers(_markers.values.toSet());

    _markerCounter++;
  }

  void _removeMarker() {
    if (_markers.isNotEmpty) {
      final lastKey = _markers.keys.last;
      _markers.remove(lastKey);
    }
  }

  void onAddPolyline() {
    final polylineId = PolylineId('polyline_${_polylines.length + 1}');

    final polyline = AnimatedPolyline(
      polyline: Polyline(
        polylineId: polylineId,
        color: Colors.purple,
        width: 4,
        points: MapAnimationUtils.generateEquidistantPolylineByDuration(
          path: polylineList2,
          duration: const Duration(seconds: 5),
        ),
      ),
      polylineAnimator: SnackAnimator(repeat: true, curve: Curves.linear, duration: const Duration(seconds: 5)),
    );

    _polylines.add(polyline);
    mapAnimationController?.updatePolylines(_polylines);
  }

  void onRemovePolyline() {
    if (_polylines.isNotEmpty) {
      final lastPolyline = _polylines.last;
      _polylines.remove(lastPolyline);
      mapAnimationController?.updatePolylines(_polylines);
    }
  }

  LatLng generateRandomLatLngInRadius(LatLng center, double radiusInMeters) {
    final random = Random();

    final double distance = radiusInMeters * sqrt(random.nextDouble());
    final double angle = random.nextDouble() * 2 * pi;

    final double deltaLat = distance / 111320.0;
    final double deltaLng = distance / (111320.0 * cos(center.latitude * pi / 180));

    final double newLat = center.latitude + deltaLat * cos(angle);
    final double newLng = center.longitude + deltaLng * sin(angle);

    return LatLng(newLat, newLng);
  }

  Stream<LatLng> generateLatLngStream(LatLng startPoint, double radiusInMeters, Duration interval) async* {
    LatLng lastLatLng = startPoint;
    while (true) {
      await Future.delayed(interval);
      lastLatLng = generateRandomLatLngInRadius(lastLatLng, radiusInMeters);
      yield lastLatLng;
    }
  }
}
