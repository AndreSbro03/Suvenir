import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_tok/media_info.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.video});

  final AssetEntity video;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {

  late final Future<File?> videoFile;
  late final VideoPlayerController _videoPlayerController;
  bool initialized = false;

  _initVideo() async {
    videoFile = widget.video.file;
    final video = await videoFile;
    _videoPlayerController = VideoPlayerController.file(video!)
      ..setLooping(true)
      ..play()
      ..initialize().then(
        (_) => setState(() => initialized = true),
      );
  }

  @override
  void initState(){
    _initVideo();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: 
          initialized
          ? 
          AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          )
          :  
          const CircularProgressIndicator(),
        ),
        if(initialized) Center(
          child: IconButton(
            onPressed: () {
              setState(() {
                _videoPlayerController.value.isPlaying
                      ? _videoPlayerController.pause()
                      : _videoPlayerController.play();
                });
              },
            icon: Icon(
                _videoPlayerController.value.isPlaying ? null : Icons.play_arrow,
                size: 60,
                color: Colors.white,
              ),
          )
        ),
        MediaInfo(media: widget.video)
      ]
    );
  }
}