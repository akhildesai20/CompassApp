import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

/// Exposes a continuous stream of heading degrees (0–360).
/// Null readings are filtered out; the last valid heading is cached.
class HeadingProvider {
  HeadingProvider._();

  static final _controller = StreamController<double>.broadcast();

  static Stream<double> get stream => _controller.stream;

  static void init() {
    FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading != null) _controller.add(heading);
    });
  }

  static void dispose() => _controller.close();
}
