import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../animator/base/polyline_animator.dart';
import '../controllers/map_animation_controller.dart';
import '../controllers/polyline_controller.dart';

/// Manages the animation of multiple polylines on a map.
///
/// This class handles the creation, updating, and disposal of polyline animations,
/// ensuring that animations run smoothly and are properly managed through their lifecycle.
class AnimatedPolylineManager {
  /// Map of controllers for each animated polyline, keyed by PolylineId
  final Map<PolylineId, PolylineAnimationController> _controllers = {};

  /// Ticker provider for animations
  final TickerProvider _vsync;

  /// Callback invoked when a polyline is updated during animation
  final PolylineListener _listener;

  AnimatedPolylineManager({
    required TickerProvider vsync,
    required PolylineListener polylineListener,
  }) : _vsync = vsync,
       _listener = polylineListener;

  List<PolylineId> get activePolylineIds => _controllers.keys.toList();

  void push({
    required Polyline polyline,
    required PolylineAnimator polylineAnimator,
  }) {
    PolylineAnimationController createController() => PolylineAnimationController(
      vsync: _vsync,
      polylineListener: _listener,
      polylineAnimator: polylineAnimator,
      polyline: polyline,
    );

    final controller = _controllers[polyline.polylineId];

    if (controller != null) {
      if (controller.polylineAnimator != polylineAnimator) {
        controller.dispose();
        _controllers[polyline.polylineId] = createController();
      } else {
        controller.updatePolyline(polyline);
      }
    } else {
      _controllers[polyline.polylineId] = createController();
    }
  }

  void removePolyline(PolylineId polylineId) {
    final controller = _controllers[polylineId];

    if (controller != null) {
      controller.dispose();
      _controllers.remove(polylineId);
    }
  }

  void removePolylines(Set<PolylineId> polylineIds) {
    for (final id in polylineIds) {
      removePolyline(id);
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}
