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


// Open the video file/asset
    await player.open(Media('asset:///$videoPath'));

    // Wait for tracks to be available and set audio track
    await Future.delayed(Duration(milliseconds: 500));


    // Print all available audio track names
    final audioTracks = player.state.tracks.audio;
    print('Available audio tracks:');
    for (int i = 0; i < audioTracks.length; i++) {
      final track = audioTracks[i];
      print('  Track $i: id="${track.id}", title=1"${track.title}", language="${track.language}"');
    }

    // Find and set the audio track by language code
    String targetLanguageCode;
    if (language == "English") {
      targetLanguageCode = "eng";
    } else if (language == "German") {
      targetLanguageCode = "ger";
    } else if (language == "French") {
      targetLanguageCode = "fre";
    } else if (language == "Dutch") {
      targetLanguageCode = "nld";
    } else if (language == "Italian") {
      targetLanguageCode = "ita";
    } else if (language == "Spanish") {
      targetLanguageCode = "spa";
    } else {
      throw Exception('Language "$language" not supported!');
    }

    final selectedTrack = audioTracks.where((track) => track.language == targetLanguageCode).firstOrNull;
    if (selectedTrack == null) {
      throw Exception('Audio track with language "$targetLanguageCode" not found');
    }
    await player.setAudioTrack(selectedTrack);


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