import 'package:google_map_animation/src/utils/spherical_util.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Generates points spaced dynamically based on duration

final class MapAnimationUtils {
  MapAnimationUtils._();

  static List<LatLng> generateEquidistantPolylineByDuration({
    required List<LatLng> path,
    required Duration duration,
    int frameIntervalMs = 16, // e.g. 60 FPS
  }) {
    if (path.length < 2 || duration.inMilliseconds == 0) return path;

    double totalDistance = 0;
    for (int i = 0; i < path.length - 1; i++) {
      totalDistance += SphericalUtil.computeDistanceBetween(
        path[i],
        path[i + 1],
      );
    }

    int steps = duration.inMilliseconds ~/ frameIntervalMs;
    if (steps == 0) return path;

    double spacingMeters = totalDistance / steps;

    return _createEquidistantPoints(path, spacingMeters);
  }

  /// Generates a list of LatLng points spaced evenly in meters along a polyline path
  static List<LatLng> _createEquidistantPoints(
    List<LatLng> path,
    double spacingMeters,
  ) {
    if (path.length < 2) return path;

    List<LatLng> result = [path.first];
    double remaining = 0.0;

    for (int i = 0; i < path.length - 1; i++) {
      LatLng start = path[i];
      LatLng end = path[i + 1];
      final segmentLength = SphericalUtil.computeDistanceBetween(start, end);
      double distanceCovered = 0.0;

      while ((remaining + distanceCovered) < segmentLength) {
        double fraction = (remaining + distanceCovered) / segmentLength;
        result.add(SphericalUtil.interpolate(start, end, fraction));
        distanceCovered += spacingMeters;
      }

      remaining = (remaining + segmentLength - distanceCovered) % spacingMeters;
    }

    return result;
  }
}
