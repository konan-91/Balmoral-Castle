import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'main.dart';

class VideoPlayer extends StatefulWidget {
  final String videoNumber;

  const VideoPlayer({required this.videoNumber, super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with TickerProviderStateMixin {
  late final Player player;
  late final VideoController controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  // Add explicit state tracking for play/pause
  bool _isPlaying = false;
  StreamSubscription<bool>? _playingSubscription;

  static const Map<String, String> _languageMap = {
    "English": "eng",
    "German": "ger",
    "French": "fre",
    "Dutch": "nld",
    "Italian": "ita",
    "Spanish": "spa",
  };

  @override
  void initState() {
    super.initState();
    _initializePlayer();
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
      setState(() {
        _showControls = true;
      });
      _fadeController.forward();
    }
    // Only start hide timer if video is playing
    if (_isPlaying) {
      _startHideTimer();
    }
  }

  void _hideControls() {
    if (_showControls) {
      _fadeController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsTemporarily();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _playingSubscription?.cancel();
    _fadeController.dispose();
    player.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      MediaKit.ensureInitialized();

      player = Player();
      controller = VideoController(player);

      final language = Provider.of<LanguageProvider>(context, listen: false).language;
      final targetLanguage = _languageMap[language];

      if (targetLanguage == null) {
        throw Exception('Language "$language" not supported');
      }

      await player.open(Media('asset:///assets/videos/${widget.videoNumber}.mp4'));
      await player.pause();

      final tracks = await player.stream.tracks.firstWhere((t) => t.audio.isNotEmpty);
      await _selectAudioTrack(tracks.audio, targetLanguage);

      // Listen to play/pause state changes with explicit state management
      _playingSubscription = player.stream.playing.listen((isPlaying) {
        if (mounted) {
          setState(() {
            _isPlaying = isPlaying;
          });

          if (isPlaying && _showControls) {
            _startHideTimer();
          } else if (!isPlaying) {
            _showControlsTemporarily();
          }
        }
      });

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  Future<void> _selectAudioTrack(List<AudioTrack> audioTracks, String targetLanguage) async {
    debugPrint('Available audio tracks:');
    for (int i = 0; i < audioTracks.length; i++) {
      final track = audioTracks[i];
      debugPrint('  Track $i: id="${track.id}", title="${track.title}", language="${track.language}"');
    }

    final selectedTrack = audioTracks
        .where((track) => track.language == targetLanguage)
        .firstOrNull;

    if (selectedTrack != null) {
      await player.setAudioTrack(selectedTrack);
    } else {
      throw Exception('Audio track with language "$targetLanguage" not found');
    }
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
        ? Video(
      controller: controller,
      controls: null,
      fill: regalBlue,
    )
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
        stream: player.stream.position,
        builder: (context, snapshot) {
          final position = snapshot.data ?? Duration.zero;
          final duration = player.state.duration;

          String formatTime(Duration d) {
            final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
            final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
            return '$minutes:$seconds';
          }

          final posMillis = position.inMilliseconds.toDouble();
          final durMillis = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use the explicit state instead of StreamBuilder
              IconButton(
                iconSize: 54,
                color: Colors.white,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  if (_isPlaying) {
                    await player.pause();
                  } else {
                    await player.play();
                  }
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
                        player.seek(Duration(milliseconds: value.toInt()));
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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
            mini: false,
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
              "Video ${widget.videoNumber}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}