import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// This abstract class defines the properties needed to animate a polyline
/// on a Google Map
abstract class PolylineAnimator {
  final Duration duration;
  final Curve curve;
  final bool repeat;
  final bool reverse;

  /// Number of times to repeat the animation (null means infinite)
  final int? repeatCount;

  const PolylineAnimator({
    required this.duration,
    this.curve = Curves.linear,
    this.repeat = false,
    this.repeatCount,
    this.reverse = false,
  });

  Polyline animate(Polyline polyline, double progress);

  void onAnimationStop() {}

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PolylineAnimator &&
        duration == other.duration &&
        curve == other.curve &&
        repeat == other.repeat &&
        repeatCount == other.repeatCount &&
        reverse == other.reverse;
  }

  @override
  int get hashCode =>
      duration.hashCode ^ curve.hashCode ^ repeat.hashCode ^ (repeatCount?.hashCode ?? 0) ^ reverse.hashCode;

  @override
  String toString() {
    return 'PolylineAnimator{duration: $duration, curve: $curve, repeat: $repeat, repeatCount: $repeatCount, reverse: $reverse}';
  }
}
