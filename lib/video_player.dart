import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Initialize MediaKit
    MediaKit.ensureInitialized();

    // Create the player instance
    player = Player();

    // Create the video controller
    controller = VideoController(player);

    // Create path to video and audio
    String language = Provider.of<LanguageProvider>(context, listen: false).language;
    String videoPath = 'assets/videos/${widget.videoNumber}.mp4';

    await player.open(Media('asset:///$videoPath'));
    await player.pause();

    // Wait for tracks to be available - don't use set delay...
    final tracks = await player.stream.tracks.firstWhere((t) => t.audio.isNotEmpty);
    final audioTracks = tracks.audio;

    // DEBUGGING PRINTING!!
    print('Available audio tracks:');
    for (int i = 0; i < audioTracks.length; i++) {
      final track = audioTracks[i];
      print('  Track $i: id="${track.id}", title=1"${track.title}", language="${track.language}"');
    }
    // DEBUGGING END!!

    String targetLanguage;
    if (language == "English") {
      targetLanguage = "eng";
    } else if (language == "German") {
      targetLanguage = "ger";
    } else if (language == "French") {
      targetLanguage = "fre";
    } else if (language == "Dutch") {
      targetLanguage = "nld";
    } else if (language == "Italian") {
      targetLanguage = "ita";
    } else if (language == "Spanish") {
      targetLanguage = "spa";
    } else {
      throw Exception('Language "$language" not supported!');
    }

    final selectedTrack = audioTracks.where((track) => track.language == targetLanguage).firstOrNull;
    if (selectedTrack != null) {
      await player.setAudioTrack(selectedTrack);
      await player.play(); // Only play if correct track is available
    } else {
      throw Exception('Audio track with language "$targetLanguage" not found');
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Video ${widget.videoNumber}")),
      body: _isInitialized
          ? Video(
        controller: controller,
        // Optional: Add controls
        controls: AdaptiveVideoControls,
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}