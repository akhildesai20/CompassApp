import 'package:flutter/material.dart';
import 'compass_dial.dart';                          // the dial widget
import 'heading_provider.dart';                      // magnetometer stream
import '../../common/ui_helpers.dart';               // cardinal() helper
import '../location/location_service.dart';          // ← add this folder
import 'package:flutter/services.dart';              // for haptic feedback

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double _lastBuzzedAngle = 0;
  late Future<(double lat, double lon, String? place)> _locFut;

  @override
  void initState() {
    super.initState();
    HeadingProvider.init();
    _locFut = LocationService.getCurrent(); // kick off GPS fetch
  }

  @override
  void dispose() {
    HeadingProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<double>(
          stream: HeadingProvider.stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: Text('Move phone in a figure-8 to calibrate'),
              );
            }

            // Keep heading 0‒359 and avoid “-0°”
            final h = (snap.data! % 360 + 360) % 360;

            // ✅ Haptic feedback every 10°
            final currentStep = (h / 10).round();
            final lastStep = (_lastBuzzedAngle / 10).round();

            if (currentStep != lastStep) {
              HapticFeedback.mediumImpact();
              _lastBuzzedAngle = h;
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CompassDial(heading: h),
                  const SizedBox(height: 48),
                  Text(
                    '${h.round()}°  ${cardinal(h)}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),

                  /* ─── Location section ─── */
                  FutureBuilder<(double, double, String?)>(
                    future: _locFut,
                    builder: (context, locSnap) {
                      if (!locSnap.hasData) return const SizedBox.shrink();

                      final (lat, lon, place) = locSnap.data!;
                      final latDms = _degToDms(lat, isLat: true);
                      final lonDms = _degToDms(lon, isLat: false);

                      return Column(
                        children: [
                          if (place != null)
                            Text(
                              place,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey.shade300),
                            ),
                          Text(
                            '$latDms   $lonDms',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /* helper: decimal degrees → D°M'S"  N/E/S/W */
  String _degToDms(double deg, {required bool isLat}) {
    final dir = isLat ? (deg >= 0 ? 'N' : 'S') : (deg >= 0 ? 'E' : 'W');
    final abs = deg.abs();
    final d = abs.floor();
    final m = ((abs - d) * 60).floor();
    final s = (((abs - d) * 60 - m) * 60).round();
    return '$d°${m}\'${s}" $dir';
  }
}
