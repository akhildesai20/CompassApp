import 'dart:math' as math;
import 'dart:ui' as ui;       // ← NEW
import 'package:flutter/material.dart';

class CompassDial extends StatelessWidget {
  final double heading; // 0-359 cleaned in the screen widget
  const CompassDial({super.key, required this.heading});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size.square(300), painter: _CompassPainter(heading));
}

/* ─────────────────────────────────────────────────────────── */

class _CompassPainter extends CustomPainter {
  final double heading;
  _CompassPainter(this.heading);

  // basic paints reused
  final Paint _tickPaint = Paint()
    ..color = Colors.white
    ..isAntiAlias = true;

  final Paint _crossPaint = Paint()
    ..color = Colors.grey.shade800
    ..strokeWidth = 1
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final rad = heading * math.pi / 180; // clockwise

    /*──── 1. ROTATING DIAL (spins opposite heading, offset −90°) ────*/
    canvas.save();
    canvas.translate(c.dx, c.dy);          // pivot about centre
    canvas.rotate(-(rad + math.pi / 2));   // spin + shift
    canvas.translate(-c.dx, -c.dy);        // restore origin

    /* 1-a tick ring every 10° */
    for (int d = 0; d < 360; d += 10) {
      final major = d % 30 == 0;
      final len   = major ? r * .12 : r * .07;
      _tickPaint.strokeWidth = major ? 1.4 : 0.8;

      final a = d * math.pi / 180;
      final p1 = c + Offset(math.cos(a), math.sin(a)) * (r - len);
      final p2 = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawLine(p1, p2, _tickPaint);
    }

    /* 1-b Cardinal directions (N, E, S, W) aligned radially */
    const dirs = ['N', 'E', 'S', 'W'];
    const dirStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < 4; i++) {
      final angle = i * 90 * math.pi / 180; // 0, 90, 180, 270 degrees in radians
      final pos = c + Offset(math.cos(angle), math.sin(angle)) * (r * 1.10);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // Radial alignment: rotate 90° counterclockwise from angle
      canvas.rotate(angle + math.pi / 2);

      _drawCenteredText(canvas, dirs[i], Offset.zero, dirStyle);
      canvas.restore();
    }

    /* 1-c  radially-aligned degree numbers (every 30 °) */
    const textStyle = TextStyle(color: Colors.grey, fontSize: 12);

    for (int d = 30; d < 360; d += 30) {
      final a   = d * math.pi / 180;                       // absolute angle
      final pos = c + Offset(math.cos(a), math.sin(a)) * (r * .80);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // Tangential baseline → rotate 90° counter-clockwise from radial
      double rot = a + math.pi / 2;

      canvas.rotate(rot);

      _drawCenteredText(canvas, '$d', Offset.zero, textStyle);
      canvas.restore();
    }


/* 1-d  cross-hair  (70 % of dial radius) */
    final double crossLen = r * 0.70;              // ← adjust this factor
    canvas.drawLine(c + Offset(-crossLen, 0), c + Offset(crossLen, 0), _crossPaint);
    canvas.drawLine(c + Offset(0, -crossLen), c + Offset(0, crossLen), _crossPaint);


    /* 1-e subtle inner fill */
    canvas.drawCircle(c, r * 0.25, Paint()..color = const Color(0xFF1A1A1A).withOpacity(0.50));

    canvas.restore(); // ─── dial finished ───

    /*──── 2.  FIXED pie-style sweep with radial fade  ────*/
    final double innerRadius = 0;          // centre point
    final double outerRadius = r * 1.25;    // same as dial rim used before

// Path: centre → arc → back to centre (a sector)
    final Path sector = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(
        Rect.fromCircle(center: c, radius: outerRadius),
        (-120) * math.pi / 180,           // start angle
        60 * math.pi / 180,               // sweep angle
        false,
      )
      ..close();

// Paint with radial gradient: red at centre → transparent at rim
    final Paint sectorPaint = Paint()
      ..shader = ui.Gradient.radial(
        c,                                // centre
        outerRadius,                      // radius
        [
          Colors.red.withOpacity(0.5),                     // 0 %  (centre) opaque red
          Colors.red.withOpacity(0.0),    // 100 % (rim) fully transparent
        ],
      );

    canvas.drawPath(sector, sectorPaint);

    /*──── 2-b.  smaller hub circle overlays the wedge ────*/
    const hubFill = Color(0xFF010101);      // same subtle grey
    final double hubRadius = r * .1;       // tweak to taste (was 0.30)

    canvas.drawCircle(c, hubRadius, Paint()..color = hubFill);


    /*──── 3. FIXED red triangle pointer ────*/
    final triBase = c + Offset(0, -r - 4);
    final tri = Path()
      ..moveTo(triBase.dx, triBase.dy)
      ..relativeLineTo(-6, 10)
      ..relativeLineTo(12, 0)
      ..close();
    canvas.drawPath(tri, Paint()..color = Colors.red);

// ──4. Footer Text
    const footerText = 'Created with ❤️ by Akhil Desai';
    const footerStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    final footerOffset = Offset(c.dx, c.dy + r + 225);
    _drawCenteredText(canvas, footerText, footerOffset, footerStyle);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) => old.heading != heading;

  /* helper: draw txt centred on given pos */
  void _drawCenteredText(Canvas canvas, String txt, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: txt, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }
}