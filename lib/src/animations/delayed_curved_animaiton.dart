import 'dart:math' as math;

import 'package:flutter/material.dart';

class DelayedCurvedAnimation extends CurvedAnimation {
  final Duration delayStart;
  final Duration delayEnd;
  final Duration totalDuration;
  final Duration animationDuration;

  DelayedCurvedAnimation({
    required AnimationController controller,
    required this.totalDuration,
    this.delayStart = Duration.zero,
    this.delayEnd = Duration.zero,
    Curve curve = Curves.linear,
  }) : animationDuration = Duration(
         microseconds: totalDuration.inMicroseconds - delayStart.inMicroseconds - delayEnd.inMicroseconds,
       ),
       super(
         parent: controller,
         curve: _calculateAnimationInterval(totalDuration, delayStart, delayEnd, curve),
       );

  static Interval _calculateAnimationInterval(
    Duration totalDuration,
    Duration delayStart,
    Duration delayEnd,
    Curve curve,
  ) {
    final totalMicroseconds = totalDuration.inMicroseconds;

    // Validation
    if (delayStart.inMicroseconds + delayEnd.inMicroseconds >= totalMicroseconds) {
      throw ArgumentError(
        'Combined delays (${delayStart.inMilliseconds}ms + ${delayEnd.inMilliseconds}ms) '
        'cannot exceed total duration (${totalDuration.inMilliseconds}ms)',
      );
    }

    final startRatio = delayStart.inMicroseconds / totalMicroseconds;
    final endRatio = delayEnd.inMicroseconds / totalMicroseconds;

    return Interval(startRatio, 1 - endRatio, curve: curve);
  }

  // Helper method to get the actual animation progress (0-1) during animation phase
  double get animationProgress {
    if (value == 0.0) return 0.0;
    if (value == 1.0) return 1.0;

    final startRatio = delayStart.inMicroseconds / totalDuration.inMicroseconds;
    final endRatio = delayEnd.inMicroseconds / totalDuration.inMicroseconds;
    final animationRatio = 1 - startRatio - endRatio;

    if (animationRatio <= 0) return 0.0;

    return math.max(0.0, math.min(1.0, (value - startRatio) / animationRatio));
  }

  bool get isInStartDelay => parent.value < (delayStart.inMicroseconds / totalDuration.inMicroseconds);
  bool get isInEndDelay => parent.value > (1 - delayEnd.inMicroseconds / totalDuration.inMicroseconds);

  @override
  bool get isAnimating => !isInStartDelay && !isInEndDelay;
}
