import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../provider/media_answer_provider.dart';
import '../provider/question_text_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/gradient_button.dart';
import '../widgets/step_header.dart';
import '../widgets/video_recorder_widget.dart';
import 'submission_success_screen.dart';

class OnboardingQuestionScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState
    extends ConsumerState<OnboardingQuestionScreen> {
  final _textController = TextEditingController();

  // Audio
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _recorderReady = false;
  double _dbLevel = 0;
  Duration _elapsed = Duration.zero;
  Timer? _tick;

  // Video
  CameraController? _camera;
  VideoPlayerController? _videoPlayer;

  @override
  void initState() {
    super.initState();
    _setupAudio();
    _player.openPlayer();

    _textController.text = ref.read(answerTextProvider);
    _textController.addListener(() {
      final v = _textController.text;
      if (v.length > 600) {
        _textController.text = v.substring(0, 600);
        _textController.selection = TextSelection.collapsed(
          offset: _textController.text.length,
        );
      }
      ref.read(answerTextProvider.notifier).state = _textController.text;
    });
  }

  // --------------------------------------------------------------
  // AUDIO SETUP
  // --------------------------------------------------------------
  Future<void> _setupAudio() async {
    await _recorder.openRecorder();
    _recorderReady = true;
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 80));
    _recorder.onProgress?.listen((p) {
      if (!mounted) return;
      setState(() => _dbLevel = p.decibels ?? 0);
    });
  }

  Future<bool> _ensureMic() async =>
      (await Permission.microphone.request()).isGranted;

  Future<String> _tempFile(String ext) async {
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/hotspot_$ts.$ext';
  }

  Future<void> _startAudio() async {
    if (!_recorderReady) return;
    if (!await _ensureMic()) return;

    _elapsed = Duration.zero;
    final path = await _tempFile('aac');
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);

    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });

    ref.read(mediaStateProvider.notifier).setAudioRecording(true);
  }

  Future<void> _stopAudio() async {
    if (_recorder.isRecording) {
      final savedPath = await _recorder.stopRecorder();
      _tick?.cancel();
      ref.read(mediaStateProvider.notifier).setAudioRecording(false);
      if (savedPath != null) {
        ref.read(mediaStateProvider.notifier).setAudioPath(savedPath);
      }
    }
  }

  Future<void> _cancelAudio() async {
    _tick?.cancel();
    _elapsed = Duration.zero;

    final media = ref.read(mediaStateProvider);
    if (_recorder.isRecording) {
      final p = await _recorder.stopRecorder();
      if (p != null) {
        try {
          File(p).deleteSync();
        } catch (_) {}
      }
    }
    if (media.audioPath != null) {
      try {
        File(media.audioPath!).deleteSync();
      } catch (_) {}
      ref.read(mediaStateProvider.notifier).clearAudio();
    }
    ref.read(mediaStateProvider.notifier).setAudioRecording(false);
  }

  Future<void> _playAudio(String path) async {
    if (_player.isPlaying) {
      await _player.stopPlayer();
      return;
    }
    await _player.startPlayer(fromURI: path);
  }

  Future<void> _deleteAudio() async {
    final p = ref.read(mediaStateProvider).audioPath;
    if (p != null) {
      try {
        File(p).deleteSync();
      } catch (_) {}
      ref.read(mediaStateProvider.notifier).clearAudio();
    }
  }

  // --------------------------------------------------------------
  // VIDEO SETUP
  // --------------------------------------------------------------
  Future<bool> _ensureCamAndMic() async {
    final result = await [Permission.camera, Permission.microphone].request();
    return result[Permission.camera]!.isGranted &&
        result[Permission.microphone]!.isGranted;
  }

  Future<void> _ensureCameraInitialized() async {
    if (_camera != null) return;
    if (!await _ensureCamAndMic()) return;

    final cams = await availableCameras();
    final cam = cams.isNotEmpty ? cams.first : null;
    if (cam == null) return;

    _camera = CameraController(cam, ResolutionPreset.medium, enableAudio: true);
    await _camera!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startVideo() async {
    await _ensureCameraInitialized();
    final c = _camera;
    if (c == null || c.value.isRecordingVideo) return;
    await c.startVideoRecording();
    ref.read(mediaStateProvider.notifier).setVideoRecording(true);
  }

  Future<void> _stopVideo() async {
    final c = _camera;
    if (c == null || !c.value.isRecordingVideo) return;
    final file = await c.stopVideoRecording();
    ref.read(mediaStateProvider.notifier).setVideoRecording(false);
    ref.read(mediaStateProvider.notifier).setVideoPath(file.path);
    await _loadVideoPlayer(file.path);
  }

  Future<void> _loadVideoPlayer(String path) async {
    _videoPlayer?.dispose();
    _videoPlayer = VideoPlayerController.file(File(path));
    await _videoPlayer!.initialize();
    setState(() {});
  }

  Future<void> _deleteVideo() async {
    final p = ref.read(mediaStateProvider).videoPath;
    if (p != null) {
      try {
        File(p).deleteSync();
      } catch (_) {}
      ref.read(mediaStateProvider.notifier).clearVideo();
    }
    _videoPlayer?.dispose();
    _videoPlayer = null;
    setState(() {});
  }

  // --------------------------------------------------------------
  // RESET ALL STATE AFTER SUBMIT
  // --------------------------------------------------------------
  void _resetAllState() {
    _tick?.cancel();
    _elapsed = Duration.zero;
    _dbLevel = 0;

    final media = ref.read(mediaStateProvider);

    if (media.audioPath != null) {
      try {
        File(media.audioPath!).deleteSync();
      } catch (_) {}
    }
    if (media.videoPath != null) {
      try {
        File(media.videoPath!).deleteSync();
      } catch (_) {}
    }

    ref.read(mediaStateProvider.notifier).reset();
    ref.read(answerTextProvider.notifier).state = '';
    _textController.clear();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _textController.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    _camera?.dispose();
    _videoPlayer?.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // UI
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final text = ref.watch(answerTextProvider);
    final media = ref.watch(mediaStateProvider);

    final allowSubmit =
        text.trim().isNotEmpty ||
        media.audioPath != null ||
        media.videoPath != null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            children: [
              StepHeader(
                step: 2,
                total: 2,
                onBack: () => Navigator.pop(context),
                onClose: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tell us about your hosting experience',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 4,
                  maxLength: 600,
                  decoration: const InputDecoration(
                    labelText: 'Write your answer (max 600 chars)',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AudioRecorderWidget(
                  isRecording: media.isRecordingAudio,
                  dbLevel: _dbLevel,
                  elapsed: _elapsed,
                  audioPath: media.audioPath,
                  onStart: _startAudio,
                  onStop: _stopAudio,
                  onCancel: _cancelAudio,
                  onPlay: media.audioPath != null
                      ? () => _playAudio(media.audioPath!)
                      : null,
                  onDelete: _deleteAudio,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.33,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: VideoRecorderWidget(
                    cameraController: _camera,
                    videoPlayerController: _videoPlayer,
                    isRecording: media.isRecordingVideo,
                    videoPath: media.videoPath,
                    onStart: _startVideo,
                    onStop: _stopVideo,
                    onDelete: _deleteVideo,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 22,
                ),
                child: GradientButton(
                  label: 'Submit',
                  onPressed: allowSubmit
                      ? () {
                          final payload = {
                            'text': text,
                            'audioPath': media.audioPath,
                            'videoPath': media.videoPath,
                          };
                          print('Screen 2 state => $payload');

                          _resetAllState(); // ✅ clear everything

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubmissionSuccessScreen(),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
