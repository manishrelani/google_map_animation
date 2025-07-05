# Google Maps Animation Flutter Library

A powerful Flutter library for creating smooth, customizable polyline and marker animations on Google Maps. Bring your maps to life with beautiful animations that enhance user experience.


## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  google_map_animation: ^1.0.0
  google_maps_flutter: ^2.12.3
```

## Quick Start

### 1. Basic Setup

```dart
import 'package:google_map_animation/google_map_animation.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> 
    with TickerProviderStateMixin {
  GoogleMapController? mapController;
  MapAnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          animationController = MapAnimationController(
            mapId: controller.mapId,
            vsync: this,
          );
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 12,
        ),
      ),
    );
  }
}
```

### 2. Snake Animation

Create a drawing/erasing animation effect:

```dart
final snakePolyline = AnimatedPolyline(
  polyline: Polyline(
    polylineId: PolylineId('snake'),
    points: [
      LatLng(37.7749, -122.4194),
      LatLng(37.7849, -122.4094),
      LatLng(37.7949, -122.3994),
      // Add more points...
    ],
    color: Colors.blue,
    width: 5,
  ),
  polylineAnimator: SnackAnimator(
    duration: Duration(seconds: 3),
    repeat: true,
    curve: Curves.easeInOut,
  ),
);

// Add to map
animationController?.updatePolylines({snakePolyline});
```

### 3. Color Transition Animation

Animate between multiple colors:

```dart
final colorPolyline = AnimatedPolyline(
  polyline: Polyline(
    polylineId: PolylineId('color'),
    points: yourPolylinePoints,
    width: 8,
  ),
  polylineAnimator: ColorTransitionAnimation(
    colors: [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
    ],
    duration: Duration(seconds: 5),
    repeat: true,
  ),
);
```

### 4. Marker Animation

Animate markers with smooth transitions:

```dart
// Create markers
final markers = {
  Marker(
    markerId: MarkerId('marker1'),
    position: LatLng(37.7749, -122.4194),
  ),
  Marker(
    markerId: MarkerId('marker2'),
    position: LatLng(37.7849, -122.4094),
  ),
};

// Update markers with animation
animationController?.updateMarkers(markers);
```


### Custom Animation Duration and Optimization

Use `MapAnimationUtils` to create optimized polylines:

```dart
final optimizedPoints = MapAnimationUtils.generateEquidistantPolylineByDuration(
  path: originalPoints,
  duration: Duration(seconds: 5),
  frameIntervalMs: 16, // 60 FPS
);

final polyline = AnimatedPolyline(
  polyline: Polyline(
    polylineId: PolylineId('optimized'),
    points: optimizedPoints,
    color: Colors.purple,
    width: 4,
  ),
  polylineAnimator: CustomAnimator(
    duration: Duration(seconds: 5),
    repeat: true,
  ),
);
```

### Creating Custom Animators

Extend `PolylineAnimator` to create your own effects:

```dart
class CustomAnimator extends PolylineAnimator {
 

  const CustomAnimator({
    super.duration = const Duration(seconds: 1),
    super.repeat = true,
  });

  @override
  Polyline animate(Polyline polyline, double progress) {
    // Add your custom animation logic here
    return polyline;
  }
}
```


## Animation Types

### Built-in Animators

| Animator | Description | Use Case |
|----------|-------------|----------|
| `SnackAnimator` | Drawing/erasing effect | Route visualization, progress indication |
| `ColorTransitionAnimation` | Color morphing | Status changes, temperature maps |

### Animation Properties

All animators support these properties:

- `duration`: Animation duration
- `curve`: Animation curve (Curves.linear, Curves.easeIn, etc.)
- `repeat`: Whether to repeat the animation
- `repeatCount`: Number of repetitions (null for infinite)
- `reverse`: Whether to reverse the animation



## API Reference

### MapAnimationController

Main controller for managing animations:

```dart
MapAnimationController({
  required int mapId,
  required TickerProvider vsync,
  Set<Marker> markers = const {},
  Set<AnimatedPolyline> polylines = const {},
  Duration markersAnimationDuration = const Duration(milliseconds: 2000),
  MarkerListener? markerListener,
})
```


## License

This project is licensed under the BSD License - see the [LICENSE](LICENSE) file for details.




Made with ❤️ by Manish Relani for the Flutter community
