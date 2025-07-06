import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/marker_controller.dart';

class AnimatedMarkersManager {
  AnimatedMarkersManager({
    required TickerProvider vsync,
    required Duration duration,
    required this.onUpdateMarkers,
    required this.onRemoveMarkers,
  }) {
    // 16.67 ms per frame for 60 FPS (1000 ms / 60 FPS) ~= 16.67 ms
    totalFrames = (duration.inMilliseconds / 16.67).round();

    _animationController = AnimationController(vsync: vsync, duration: duration)
      ..addStatusListener(_statusListener)
      ..addListener(listener);
  }

  late final int totalFrames;
  late final AnimationController _animationController;

  final ValueChanged<Set<Marker>> onUpdateMarkers;
  final ValueChanged<Set<MarkerId>> onRemoveMarkers;

  final Map<MarkerId, MarkerController> _controllers = {};

  final Set<MarkerId> _markersToBeRemoved = {};

  int _lastFrameIndex = -1;

  bool get isAnimating => _animationController.isAnimating;

  void push(Set<Marker> markers) {
    for (var marker in markers) {
      final controller = _controllers[marker.markerId] ??= MarkerController(
        marker: marker,
        animationController: _animationController,
      );

      controller.pushToQueue(marker);
    }
    if (!isAnimating) {
      _animateMarkers();
    }
  }

  void _animateMarkers() {
    bool animationRequired = false;
    for (var controller in _controllers.values) {
      if (!animationRequired && controller.hasMarker) {
        animationRequired = true;
      }
      controller.setupNextMarker();
    }

    if (animationRequired) {
      _lastFrameIndex = -1;

      _animationController.reset();
      _animationController.forward();
    }
  }

  void removeMarker(MarkerId markerId) {
    if (!isAnimating) {
      _controllers.remove(markerId);
      onRemoveMarkers({markerId});
    } else {
      _markersToBeRemoved.add(markerId);
    }
  }

  void _clearMarkersToBeRemoved() {
    if (_markersToBeRemoved.isNotEmpty) {
      for (var markerId in _markersToBeRemoved) {
        _controllers.remove(markerId);
      }

      onRemoveMarkers(_markersToBeRemoved.toSet());
      _markersToBeRemoved.clear();
    }
  }

  void _statusListener(AnimationStatus status) {
    if (status case (AnimationStatus.completed || AnimationStatus.dismissed)) {
      _clearMarkersToBeRemoved();

      final isMarkerinQueue = _controllers.values.any((m) => m.hasMarker);

      if (isMarkerinQueue) _animateMarkers();
    }
  }

  void listener() {
    final t = _animationController.value;
    final frameIndex = (t * totalFrames).floor();

    if (frameIndex == _lastFrameIndex) return; // Skip duplicate frames
    _lastFrameIndex = frameIndex;

    final Set<Marker> markerPosition = {};

    for (var controller in _controllers.values) {
      markerPosition.add(controller.animate(_animationController.value));
    }
    onUpdateMarkers(markerPosition);
  }

  void dispose() {
    _animationController.removeStatusListener(_statusListener);
    _animationController.removeListener(listener);
    _animationController.dispose();
    _controllers.clear();
    _markersToBeRemoved.clear();
  }
}
