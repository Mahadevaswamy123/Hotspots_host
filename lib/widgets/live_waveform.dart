import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Live vertical-bar waveform that animates smoothly and scales with dB level.
/// - [levelDb]: microphone decibels from flutter_sound onProgress (can be null/NaN)
/// - [isRecording]: start/stop animation
class LiveWaveform extends StatefulWidget {
  final double? levelDb;
  final bool isRecording;
  final int bars;
  final double maxBarHeight;
  final double barWidth;
  final double spacing;
  final double radius;

  const LiveWaveform({
    super.key,
    required this.levelDb,
    required this.isRecording,
    this.bars = 24,
    this.maxBarHeight = 56,
    this.barWidth = 4,
    this.spacing = 4,
    this.radius = 4,
  });

  @override
  State<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<LiveWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 900),
          )
          ..addListener(() {
            if (mounted && widget.isRecording) setState(() {});
          })
          ..repeat();
  }

  @override
  void didUpdateWidget(covariant LiveWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    } else {
      _ctrl.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _ampFromDb(double? db) {
    // Map dB (-60..0) -> 0..1 smoothly
    final d = (db ?? -60).isFinite ? db!.clamp(-60.0, 0.0) : -60.0;
    return ((d + 60.0) / 60.0);
  }

  @override
  Widget build(BuildContext context) {
    final amp = _ampFromDb(widget.levelDb); // 0..1
    final bars = <Widget>[];
    final t = _ctrl.value; // 0..1

    for (int i = 0; i < widget.bars; i++) {
      // Phase shift per bar to get wave-like motion
      final phase = (i / widget.bars) * math.pi * 2;
      // Sinus base motion
      final base = (math.sin((t * math.pi * 2) + phase) + 1) / 2; // 0..1
      // Shape + scale by amp (keep minimum height so it never fully disappears)
      final h =
          (widget.maxBarHeight * (0.25 + 0.75 * base) * (0.35 + 0.65 * amp))
              .clamp(6.0, widget.maxBarHeight);

      bars.add(
        Container(
          width: widget.barWidth,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      );

      if (i != widget.bars - 1) {
        bars.add(SizedBox(width: widget.spacing));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: bars,
    );
  }
}
