import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/spherical_util.dart';

class LocationTween extends Tween<LatLng> {
  LocationTween({required LatLng begin, required LatLng end}) : super(begin: begin, end: end);

  @override
  LatLng get begin => super.begin!;

  @override
  LatLng get end => super.end!;

  @override
  LatLng lerp(double t) {
    return SphericalUtil.interpolate(begin, end, t);
  }

  void swap(LatLng newPosition) {
    begin = end;
    end = newPosition;
  }

  double get bearing => SphericalUtil.computeHeading(begin, end).toDouble();
}
