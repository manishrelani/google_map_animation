import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../../google_map_animation.dart';

class ColorTransitionAnimation extends PolylineAnimator {
  final List<Color> colors;

  const ColorTransitionAnimation({
    required this.colors,
    super.duration = const Duration(seconds: 5),
    super.curve = Curves.linear,
    super.repeat = false,
  });

  @override
  Polyline animate(Polyline polyline, double progress) {
    final totalColors = colors.length;
    final colorIndex = (progress * totalColors).floor() % totalColors;
    final nextColorIndex = (colorIndex + 1) % totalColors;

    final colorProgress = (progress * totalColors) - colorIndex;

    final interpolatedColor = Color.lerp(
      colors[colorIndex],
      colors[nextColorIndex],
      colorProgress,
    );

    return polyline.copyWith(
      colorParam: interpolatedColor,
    );
  }
}
