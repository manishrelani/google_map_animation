import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../google_map_animation.dart';

class FadeInProgressiveAnimator extends PolylineAnimator {
  const FadeInProgressiveAnimator({
    super.duration = const Duration(seconds: 5),
    super.curve = Curves.ease,
    super.repeat = true,
    super.repeatCount,
    super.reverse,
    super.delayStart,
    super.delayEnd,
  });

  @override
  Polyline animate(Polyline polyline, double progress) {
    if (progress <= 0.3) {
      return polyline.copyWith(colorParam: polyline.color.withValues(alpha: progress / 0.3));
    } else {
      final animationProgress = (progress - 0.3) / 0.7;
      final startIndex = (polyline.points.length * animationProgress).round();
      final points = polyline.points.skip(startIndex).toList();
      return polyline.copyWith(pointsParam: points);
    }
  }
}
