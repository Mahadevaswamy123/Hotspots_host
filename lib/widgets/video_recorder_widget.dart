import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';

class VideoRecorderWidget extends StatelessWidget {
  final CameraController? cameraController;
  final VideoPlayerController? videoPlayerController;
  final bool isRecording;
  final String? videoPath;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onDelete;

  const VideoRecorderWidget({
    super.key,
    required this.cameraController,
    required this.videoPlayerController,
    required this.isRecording,
    required this.videoPath,
    required this.onStart,
    required this.onStop,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glass(radius: 18),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.videocam, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Video Answer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (videoPath != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (videoPath == null) ...[
            if (!(cameraController?.value.isInitialized ?? false))
              const Text('Camera will preview when recording starts'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRecording ? null : onStart,
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Record Video'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isRecording ? onStop : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ] else ...[
            if (videoPlayerController != null &&
                videoPlayerController!.value.isInitialized)
              AspectRatio(
                aspectRatio: videoPlayerController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(videoPlayerController!),
                    _PlayPauseOverlay(controller: videoPlayerController!),
                  ],
                ),
              )
            else
              const Text('Video loaded'),
          ],
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          controller.value.isPlaying ? controller.pause() : controller.play(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: controller.value.isPlaying
            ? const SizedBox.shrink()
            : Container(
                color: Colors.black26,
                child: const Center(
                  child: Icon(Icons.play_arrow, size: 50, color: Colors.white),
                ),
              ),
      ),
    );
  }
}
