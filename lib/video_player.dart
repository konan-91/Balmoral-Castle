import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'main.dart';
import 'get_multiplier.dart';

class VideoPlayer extends StatefulWidget {
  final int videoNumber;

  const VideoPlayer({required this.videoNumber, super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with TickerProviderStateMixin {
  late final Player videoPlayer;
  late final Player audioPlayer;
  late final VideoController controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isPlaying = false;
  StreamSubscription<bool>? _videoPlayingSubscription;
  StreamSubscription<bool>? _audioPlayingSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
    _setupAnimations();
    _startHideTimer();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls && _isPlaying) {
        _hideControls();
      }
    });
  }

  void _showControlsTemporarily() {
    if (!_showControls) {
      setState(() => _showControls = true);
      _fadeController.forward();
    }
    if (_isPlaying) _startHideTimer();
  }

  void _hideControls() {
    if (_showControls) {
      _fadeController.reverse().then((_) {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  void _toggleControls() {
    _showControls ? _hideControls() : _showControlsTemporarily();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _videoPlayingSubscription?.cancel();
    _audioPlayingSubscription?.cancel();
    _fadeController.dispose();
    videoPlayer.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializePlayers() async {
    try {
      MediaKit.ensureInitialized();
      videoPlayer = Player();
      audioPlayer = Player();
      controller = VideoController(videoPlayer);

      final language = Provider.of<LanguageProvider>(context, listen: false).language;

      // Load soundless video
      await videoPlayer.open(Media('asset:///assets/videos/${widget.videoNumber}.mp4'));
      print('Video loaded');

      // Load audio file
      await audioPlayer.open(Media('asset:///assets/audio/${language}_${widget.videoNumber}.mp3'));
      print('Audio loaded');

      // Get speed multiplier and apply to video
      final multiplier = await getMultiplier(language, widget.videoNumber);
      await videoPlayer.setRate(multiplier);
      print('Video speed set to $multiplier');

      // Pause both players initially
      await videoPlayer.pause();
      await audioPlayer.pause();
      print('Players paused');

      // Listen to playing state changes
      _videoPlayingSubscription = videoPlayer.stream.playing.listen((isPlaying) {
        if (!mounted) return;
        setState(() => _isPlaying = isPlaying);
        isPlaying ? _startHideTimer() : _showControlsTemporarily();
      });

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Video player init error: $e');
    }
  }

  Future<void> _play() async {
    await Future.wait([
      videoPlayer.play(),
      audioPlayer.play(),
    ]);
  }

  Future<void> _pause() async {
    await Future.wait([
      videoPlayer.pause(),
      audioPlayer.pause(),
    ]);
  }

  Future<void> _seek(Duration position) async {
    await Future.wait([
      videoPlayer.seek(position),
      audioPlayer.seek(position),
    ] as Iterable<Future>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: regalBlue,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: _buildVideoPlayer(),
          ),
          if (_showControls) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return _isInitialized
        ? Video(controller: controller, controls: null, fill: regalBlue)
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildControls() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          _buildHeader(context),
          _buildCustomControls(),
        ],
      ),
    );
  }

  Widget _buildCustomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 8,
      right: 8,
      child: StreamBuilder<Duration>(
        stream: audioPlayer.stream.position, // Use audio position as reference
        builder: (context, snapshot) {
          final position = snapshot.data ?? Duration.zero;
          final duration = audioPlayer.state.duration; // Use audio duration as reference

          String formatTime(Duration d) =>
              '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

          final posMillis = position.inMilliseconds.toDouble();
          final durMillis = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 54,
                color: Colors.white,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  _isPlaying ? await _pause() : await _play();
                  _showControlsTemporarily();
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      min: 0,
                      max: durMillis,
                      value: posMillis.clamp(0, durMillis),
                      onChanged: (value) {
                        _seek(Duration(milliseconds: value.toInt()));
                        _showControlsTemporarily();
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: Text(
                          '${formatTime(position)} / ${formatTime(duration)}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          FloatingActionButton(
            backgroundColor: regalBlue,
            foregroundColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              "", // or add video title here
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}