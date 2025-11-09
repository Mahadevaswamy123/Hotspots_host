import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'live_waveform.dart';

class AudioRecorderWidget extends StatelessWidget {
  final bool isRecording;
  final double dbLevel;
  final String? audioPath;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback? onPlay;
  final VoidCallback onDelete;

  const AudioRecorderWidget({
    super.key,
    required this.isRecording,
    required this.dbLevel,
    required this.audioPath,
    required this.elapsed,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
    required this.onPlay,
    required this.onDelete,
  });

  String _fmtT1(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glass(radius: 18),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.mic, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Audio Answer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                _fmtT1(elapsed),
                style: const TextStyle(
                  fontFeatures: [],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (audioPath != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Delete audio',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Content
          if (isRecording) ...[
            // Live waveform
            Container(
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LiveWaveform(
                levelDb: dbLevel,
                isRecording: true,
                bars: 24,
                maxBarHeight: 56,
                barWidth: 4,
                spacing: 4,
                radius: 4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop & Save'),
                  ),
                ),
              ],
            ),
          ] else if (audioPath != null) ...[
            // Saved state
            OutlinedButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Audio'),
            ),
          ] else ...[
            // Idle
            OutlinedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.mic_none),
              label: const Text('Record Audio'),
            ),
          ],
        ],
      ),
    );
  }
}
