import 'dart:io';

import 'package:flutter/material.dart';
import 'package:suvenir/bars/footbar.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.video,});

  final AssetEntity video;

  @override
  State<VideoView> createState() => VideoViewState();
}

class VideoViewState extends State<VideoView> {

  late final Future<File?> videoFile;
  bool initialized = false;
  late VideoPlayerController vp;

  /// This method callable outside with: videoViewKey!.currentState?.pauseVideo(); pause the video and update
  /// the icon button.
  Future<void> pauseVideo() async {
    if (initialized) {
      print("[INFO] Pausing video!");
      await vp.pause();
      setState(() {});
    }
  }

  _initVideo() async {
    final File? videoFile = await widget.video.file;

    vp = VideoPlayerController.file(videoFile!, videoPlayerOptions: VideoPlayerOptions(
      /// With this option if the user is listening music from Spotify, for example, the video wont stop the
      /// music but will play the audio on top of it.
      mixWithOthers: true
    ))
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

    if(initialized) print("[INFO] ${vp.value.rotationCorrection}");

    return  initialized ? Stack(
      children: [
        Center(child: 
          AspectRatio(
            aspectRatio: vp.value.aspectRatio,
            child: VideoPlayer(vp),
          ),
        ),
        Align(
          // Frome the bottom up by the relative dimension of the Footbar and a bit more for margin.
          // 1.0 - (Footbar.fbHight / (getHeight(context) * 0.5)) - 0.001
          alignment: Alignment(0, 1.0 - (Footbar.fbHight / (getHeight(context) * 0.5)) - 0.001),
          child: VideoProgressIndicator(
            vp, 
            allowScrubbing: true, 
            colors: const VideoProgressColors(playedColor: kContrColor),
          ),
        ),        
        Center(
          child: IconButton(
              onPressed: () {
              setState(() {
                if(vp.value.isPlaying){
                  vp.pause();
                } else {
                  vp.play();
                }
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