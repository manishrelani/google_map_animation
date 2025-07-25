import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../animations/delayed_curved_animaiton.dart';
import '../animator/base/polyline_animator.dart';

/// Controls the animation of a polyline.
///
/// This class manages the animation lifecycle and state for a polyline animation,
/// including starting, stopping, and updating the animation based on the configuration.
class PolylineAnimationController {
  /// The ticker provider that drives the animation
  final TickerProvider vsync;
  final PolylineAnimator polylineAnimator;
  final void Function(Polyline) polylineListener;
  late final AnimationController _controller;
  late final Animation<double> _curvedAnimation;

  Polyline _polyline;

  bool get isAnimating => _controller.isAnimating;

  PolylineAnimationController({
    required this.vsync,
    required Polyline polyline,
    required this.polylineAnimator,
    required this.polylineListener,
  }) : _polyline = polyline {
    _initialize();
  }

  void _initialize() {
    _controller =
        AnimationController(vsync: vsync, duration: polylineAnimator.duration)
          ..addListener(_listener)
          ..addStatusListener(_statusListener);

    if (polylineAnimator.delayStart != Duration.zero ||
        polylineAnimator.delayEnd != Duration.zero) {
      _curvedAnimation = DelayedCurvedAnimation(
        controller: _controller,
        totalDuration:
            polylineAnimator.duration +
            polylineAnimator.delayStart +
            polylineAnimator.delayEnd,
        delayStart: polylineAnimator.delayStart,
        delayEnd: polylineAnimator.delayEnd,
        curve: polylineAnimator.curve,
      );
    } else {
      _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: polylineAnimator.curve,
      );
    }

    if (polylineAnimator.repeat) {
      _controller.repeat(
        reverse: polylineAnimator.reverse,
        count: polylineAnimator.repeatCount,
      );
    } else {
      _controller.forward();
    }
  }

  void updatePolyline(Polyline polyline) {
    _polyline = polyline;
  }

  void _listener() {
    final progress = _curvedAnimation.value;
    final animatedPolyline = polylineAnimator.animate(_polyline, progress);
    polylineListener(animatedPolyline);
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      polylineAnimator.onAnimationStop();
    }
  }

  void dispose() {
    _controller.removeListener(_listener);
    _controller.removeStatusListener(_statusListener);

    _controller.dispose();
  }
}
