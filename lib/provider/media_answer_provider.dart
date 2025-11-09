import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaState {
  final String? audioPath;
  final String? videoPath;
  final bool isRecordingAudio;
  final bool isRecordingVideo;

  const MediaState({
    this.audioPath,
    this.videoPath,
    this.isRecordingAudio = false,
    this.isRecordingVideo = false,
  });

  MediaState copyWith({
    String? audioPath,
    bool clearAudio = false,
    String? videoPath,
    bool clearVideo = false,
    bool? isRecordingAudio,
    bool? isRecordingVideo,
  }) {
    return MediaState(
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      videoPath: clearVideo ? null : (videoPath ?? this.videoPath),
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
    );
  }
}

class MediaNotifier extends StateNotifier<MediaState> {
  MediaNotifier() : super(const MediaState());

  void setAudioPath(String? p) => state = state.copyWith(audioPath: p);
  void clearAudio() => state = state.copyWith(clearAudio: true);

  void setVideoPath(String? p) => state = state.copyWith(videoPath: p);
  void clearVideo() => state = state.copyWith(clearVideo: true);

  void setAudioRecording(bool v) => state = state.copyWith(isRecordingAudio: v);
  void setVideoRecording(bool v) => state = state.copyWith(isRecordingVideo: v);

  /// ✅ NEW: full reset for Submit flow
  void reset() => state = const MediaState();
}

final mediaStateProvider = StateNotifierProvider<MediaNotifier, MediaState>(
  (ref) => MediaNotifier(),
);
