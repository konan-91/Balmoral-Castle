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

class _VideoPlayerState extends State<VideoPlayer> {
  late final Player player;
  late final VideoController controller;
  bool _isInitialized = false;

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
  }

  @override
  void dispose() {
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
          _buildVideoPlayer(),
          _buildHeader(context),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return _isInitialized
        ? Stack(
      children: [
        Video(
          controller: controller,
          controls: null, // Remove AdaptiveVideoControls
          fill: regalBlue,
        ),
        _buildCustomControls(),
      ],
    )
        : const Center(child: CircularProgressIndicator());
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
              StreamBuilder<bool>(
                stream: player.stream.playing,
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;
                  return IconButton(
                    iconSize: 54,
                    color: Colors.white,
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      playing ? player.pause() : player.play();
                    },
                  );
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
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24.0), // Add padding to move text away from right edge
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
              borderRadius: BorderRadius.circular(56), // Use large enough radius for circle
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
