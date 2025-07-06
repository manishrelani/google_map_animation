import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../../google_map_animation.dart';

class SnackAnimator extends PolylineAnimator {
  const SnackAnimator({
    super.duration = const Duration(seconds: 2),
    super.curve = Curves.easeInOut,
    super.repeat = false,
    super.repeatCount,
    super.reverse = false,
  });

  @override
  Polyline animate(Polyline polyline, double progress) {
    final points = polyline.points;

    List<LatLng> visiblePoints;

    if (progress <= 0.5) {
      final index = (points.length * progress * 2).round();
      visiblePoints = points.take(index).toList();
    } else {
      final eraseProgress = (progress - 0.5) * 2;
      final startIndex = (points.length * eraseProgress).round();
      visiblePoints = points.skip(startIndex).toList();
    }

    return polyline.copyWith(pointsParam: visiblePoints);
  }
}
