import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {
  final String videoPath;

  const VideoPlayer({required this.videoPath, super.key});

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

    // For assets, use the full asset path
    String assetPath;
    if (widget.videoPath.startsWith('assets/')) {
      // If it's already an asset path, use it as is
      assetPath = widget.videoPath;
    } else {
      // If it's just a filename, prepend the assets path
      assetPath = 'assets/videos/${widget.videoPath}';
    }

    // Open the video file/asset
    await player.open(Media('asset:///$assetPath'));

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
      appBar: AppBar(title: Text("Video Player")),
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