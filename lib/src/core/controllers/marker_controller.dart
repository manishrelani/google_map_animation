import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../tween/bearing_tween.dart';
import '../tween/location_tween.dart';

class MarkerController {
  final AnimationController _animationController;

  late final LocationTween _locationTween;
  late final BearingTween _bearingTween;

  Marker _currentMarker;
  Marker get currentMarker => _currentMarker;

  final Queue<Marker> _queue = Queue<Marker>();

  bool get hasMarker => _queue.isNotEmpty;

  MarkerController({
    required Marker marker,
    required AnimationController animationController,
  }) : _currentMarker = marker,
       _animationController = animationController {
    _locationTween = LocationTween(
      begin: marker.position,
      end: marker.position,
    );

    _bearingTween = BearingTween(
      begin: marker.rotation,
      end: marker.rotation,
    );

    _locationTween.animate(_animationController);
    _bearingTween.animate(_animationController);
  }

  void pushToQueue(Marker m) {
    if (_currentMarker == m) {
      return;
    }

    _queue.addLast(m);
  }

  void setupNextMarker() {
    if (_queue.isEmpty) return;
    final nextMarker = _queue.removeFirst();
    _setupTo(nextMarker);
  }

  void _setupTo(Marker m) {
    _currentMarker = m;
    _locationTween.swap(m.position);
    _bearingTween.swap(_locationTween.bearing);
  }

  Marker animate(double t) {
    return _currentMarker.copyWith(
      positionParam: _locationTween.lerp(t),
      rotationParam: _bearingTween.lerp(t),
    );
  }
}
