import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../managers/animated_marker_manager.dart';
import '../managers/animated_polyline_manager.dart';
import '../model/animated_polyline.dart';

typedef PolylineListener = void Function(Polyline);
typedef MarkerListener = void Function(Set<Marker>);

final class MapAnimationController {
  final TickerProvider vsync;

  final MarkerListener? markerListener;

  final int mapId;

  /// Duration for marker animation transitions. Default is 2 second.
  final Duration markersAnimationDuration;

  MapAnimationController({
    required this.mapId,
    required this.vsync,
    Set<Marker> markers = const {},
    Set<AnimatedPolyline> polylines = const {},
    this.markersAnimationDuration = const Duration(milliseconds: 2000),
    this.markerListener,
  }) {
    _initialize(markers, polylines);
  }

  /// Manager responsible for animating marker transitions
  late final AnimatedMarkersManager _animatedMarkersManager;

  /// Manager responsible for animating polyline drawing and updates
  late final AnimatedPolylineManager _animatedPolylineManager;

  final Map<MarkerId, Marker> _markers = {};

  final Map<PolylineId, Polyline> _polylines = {};

  void _initialize(Set<Marker> markers, Set<AnimatedPolyline> polylines) {
    // Set up the markers animation manager
    _animatedMarkersManager = AnimatedMarkersManager(
      vsync: vsync,
      duration: markersAnimationDuration,
      onUpdateMarkers: _updateMarker,
      onRemoveMarkers: _removeMarker,
    );

    // Initialize markers from widget properties
    // update directly to the map
    // newly added markers wont be updated if manager is not animating markers

    if (markers.isNotEmpty) {
      _markers.addAll(keyByMarkerId(markers));
      final markerSet = _markers.values.toSet();
      _updateMarkersOnMap({}, markerSet);

      _animatedMarkersManager.push(markerSet);
    }

    // -- Polylines Initialization --

    // Set up the polylines animation manager
    _animatedPolylineManager = AnimatedPolylineManager(
      vsync: vsync,
      polylineListener: _updatePolyline,
    );

    // Add all polylines to animate

    for (var i in polylines) {
      if (i.polylineAnimator != null) {
        _animatedPolylineManager.push(
          polyline: i.polyline,
          polylineAnimator: i.polylineAnimator!,
        );
      } else {
        // If no animation is provided, add the polyline directly to the map
        _polylines[i.polyline.polylineId] = i.polyline.clone();
      }
    }

    _updatePolylinesOnMap({}, _polylines.values.toSet());
  }

  void updateMarkers(Set<Marker> updatedMarkers) {
    final newMarkersById = keyByMarkerId(updatedMarkers);

    // Identify markers that were added, removed, or updated
    final oldIds = _markers.keys.toSet();
    final newIds = newMarkersById.keys.toSet();

    final removedIds = oldIds.difference(newIds); // Markers that no longer exist
    final addedIds = newIds.difference(oldIds); // Newly added markers

    if (removedIds.isNotEmpty) {
      for (final id in removedIds) {
        _animatedMarkersManager.removeMarker(id);
      }
    }

    // Handle added markers - if not currently animating, update immediately
    // If the marker is already being animated, it will be updated by the animation manager
    // otherwise update directly to the map
    // newly added markers wont be updated if manager is not animating the markers
    // This is to ensure that the markers are updated on the map imediately
    if (addedIds.isNotEmpty) {
      if (!_animatedMarkersManager.isAnimating) {
        _updateMarker({for (final id in addedIds) newMarkersById[id]!});
      }
    }

    // Push all new markers to the animation manager
    // so that they can be animated on marker update
    if (newMarkersById.isNotEmpty) {
      final markerSet = newMarkersById.values.toSet();

      _animatedMarkersManager.push(markerSet);
    }
  }

  /// Add/update or remove polylines on the map
  /// This method will handle both animated and non-animated polylines.
  /// If a polyline has an animator, it will be animated.
  /// If not, it will be updated directly on the map.
  void updatePolylines(Set<AnimatedPolyline> updatedPolylines) {
    final newPolyLineById = keyByPolylineId(updatedPolylines.map((p) => p.polyline));

    final oldIds = _polylines.keys.toSet();
    final newIds = newPolyLineById.keys.toSet();

    final removedIds = oldIds.difference(newIds);

    if (removedIds.isNotEmpty) {
      _animatedPolylineManager.removePolylines(removedIds);
      _removePolylines(removedIds);
    }

    if (updatedPolylines.isNotEmpty) {
      for (final p in updatedPolylines) {
        if (p.polylineAnimator != null) {
          _animatedPolylineManager.push(polyline: p.polyline, polylineAnimator: p.polylineAnimator!);
        } else {
          final poly = p.polyline;
          _updatePolyline(poly);

          // Make sure to remove controller, in case it exits before
          // no effect if controller does not exist
          _animatedPolylineManager.removePolyline(poly.polylineId);
        }
      }
    }
  }

  /// Update Polyline directly on the map
  /// This method is used to update a static polyline that does not have an animator.
  /// Useful for update the polyline on marker update using [markerListener].
  void updateStaticPolyline(Polyline polyline) {
    _updatePolyline(polyline);
  }

  void _removeMarker(Set<MarkerId> markerIds) {
    final prevMarkers = Set<Marker>.from(_markers.values);

    for (final markerId in markerIds) {
      _markers.remove(markerId);
    }
    _updateMarkersOnMap(prevMarkers, _markers.values.toSet());
  }

  void _updateMarker(Set<Marker> updatedMarkers) {
    final prevMarkers = Set<Marker>.from(_markers.values);

    for (final marker in updatedMarkers) {
      _markers[marker.markerId] = marker;
    }

    // Notify external listeners
    markerListener?.call(updatedMarkers);

    _updateMarkersOnMap(prevMarkers, _markers.values.toSet());
  }

  void _updatePolyline(Polyline updatedPolyline) {
    final prevPolylines = Set<Polyline>.from(_polylines.values);

    _polylines[updatedPolyline.polylineId] = updatedPolyline;

    _updatePolylinesOnMap(prevPolylines, _polylines.values.toSet());
  }

  void _removePolylines(Set<PolylineId> polylineIds) {
    final prevPolyline = Set<Polyline>.from(_polylines.values);

    for (final id in polylineIds) {
      _polylines.remove(id);
    }
    _updatePolylinesOnMap(prevPolyline, _polylines.values.toSet());
  }

  Future<void> _updateMarkersOnMap(Set<Marker> previous, Set<Marker> current) async {
    GoogleMapsFlutterPlatform.instance.updateMarkers(
      MarkerUpdates.from(previous, current),
      mapId: mapId,
    );
  }

  Future<void> _updatePolylinesOnMap(Set<Polyline> previous, Set<Polyline> current) async {
    GoogleMapsFlutterPlatform.instance.updatePolylines(
      PolylineUpdates.from(previous, current),
      mapId: mapId,
    );
  }

  void dispose() {
    _animatedMarkersManager.dispose();
    _animatedPolylineManager.dispose();
    _markers.clear();
    _polylines.clear();
  }
}
