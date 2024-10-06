import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
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
  late final VideoPlayerController vp;
  bool initialized = false;

  _initVideo() async {
    final videoFile = await widget.video.file;
    vp = VideoPlayerController.file(videoFile!)
      ..play()
      ..setLooping(true)
      ..initialize().then(
      (_) => setState(() => initialized = true));
  }

  @override
  void initState(){
    _initVideo();
    super.initState();
  }

  @override
  void dispose() {
    vp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return  initialized ? Stack(
      children: [
        Center(child: 
          AspectRatio(
            aspectRatio: vp.value.aspectRatio,
            child: VideoPlayer(vp),
          )
        ),
        Center(
          child: IconButton(
            onPressed: () {
            setState(() {
              vp.value.isPlaying
                    ? vp.pause()
                    : vp.play();
              });
            },
            icon: Icon(
              vp.value.isPlaying ? null : Icons.play_arrow,
              size: kIconSize * 3.0,
              color: kContrColor,
            ),
          )
        ),
      ]
    ) :
    const Center(child: CircularProgressIndicator());  
  }
}