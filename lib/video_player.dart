import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';

// For next time, consider manually writing out all 10 buttons as they never actually change, but simply have
// videos / thumbnails modified based on the current language. May solve some trouble

class VideoPlayer extends StatelessWidget {
  final String videoPath;

  const VideoPlayer({required this.videoPath, super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      videoPath,
    );

    return Scaffold(
      appBar: AppBar(title: Text("Video Player")),
      body: BetterPlayer(
        controller: BetterPlayerController(
          BetterPlayerConfiguration(),
          betterPlayerDataSource: dataSource,
        ),
      ),
    );
  }
}