import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../../google_map_animation.dart';

class AnimatedPolyline {
  final Polyline polyline;

  // If null, the polyline consider as satic.
  final PolylineAnimator? polylineAnimator;

  const AnimatedPolyline({
    required this.polyline,
    this.polylineAnimator,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is AnimatedPolyline && polyline == other.polyline && polylineAnimator == other.polylineAnimator;
  }

  @override
  int get hashCode => polyline.polylineId.hashCode;

  @override
  String toString() {
    return 'AnimatedPolyline{polyline: $polyline, polylineAnimator: $polylineAnimator}';
  }
}
