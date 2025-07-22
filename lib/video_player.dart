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
    // Debug audio tracks
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
        ? Video(
      controller: controller,
      controls: AdaptiveVideoControls,
      fill: regalBlue,
    )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: regalBlue,
            foregroundColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
            elevation: 4,
            child: const Icon(Icons.arrow_back),
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
          // Invisible placeholder to center the title
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}