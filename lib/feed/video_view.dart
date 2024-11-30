import 'dart:io';

import 'package:flutter/material.dart';
import 'package:suvenir/bars/footbar.dart';
import 'package:suvenir/feed/video_player_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.video,});

  final AssetEntity video;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {

  late final Future<File?> videoFile;
  bool initialized = false;
  late VideoPlayerController vp;
  ValueNotifier<int> reloadPlayButton = ValueNotifier<int>(0);

  void _initVideo() async {
    VideoPlayerManager.instance.request(widget.video, reloadPlayButton).then((VpNode vpn) async{
      vp = vpn.vp;
      if(vpn.reload != null) reloadPlayButton = vpn.reload!;
      setState(() => initialized = true);
    });
  }

  @override
  void initState(){
    _initVideo();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

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
          child: ValueListenableBuilder(
            valueListenable: reloadPlayButton,
            builder: (context, int value, child) {
              print("[INFO] Something change!");
              return  IconButton(
                onPressed: () async {
                  if(vp.value.isPlaying){
                    await vp.pause();
                  } else {
                    await vp.play();
                  }
                  reloadPlayButton.value++;
                },
                icon: Icon(
                  vp.value.isPlaying ? null : Icons.play_arrow,
                  size: kIconSize * 3.0,
                  color: kContrColor,
                ),
              );              
            },
          )
        ),
      ]
    ) :
    const Center(child: CircularProgressIndicator());  
  }
}