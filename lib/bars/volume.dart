import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/istances/video_player_manager.dart';
import 'package:suvenir/libraries/styles.dart';

class VolumeIconButton extends StatefulWidget {
  const VolumeIconButton({super.key, required this.feedId});

  final FeedId feedId;

  @override
  State<VolumeIconButton> createState() => _VolumeIconButtonState();
}

class _VolumeIconButtonState extends State<VolumeIconButton> {

  bool isMute = VideoPlayerManager.instance.isMute;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FeedManager.instance.getShowVolumeListener(widget.feedId),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2 * kDefPadding),
        child: RotatedBox(
          quarterTurns: 3, // Rotate 270 degrees (pi/2 clockwise)
          child: SizedBox(
            width: 150,
            child: InteractiveSlider(
              numberOfSegments: 40,
              segmentDividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: kDefPadding),
              //focusedMargin: const EdgeInsets.symmetric(horizontal: 1.5 * kDefPadding),
              unfocusedMargin: const EdgeInsets.symmetric(horizontal: 0),
              initialProgress: VideoPlayerManager.instance.volume,
              backgroundColor: kPrimaryColor,
              foregroundColor: kContrColor,
              min: 0.0,
              max: 1.0,
              onChanged: (volume) {
                VideoPlayerManager.instance.setVolume(volume);
                if(volume <= 0.0001) {
                  setState(() {
                    isMute = true;
                  });
                } 
                else {
                  setState(() {
                    isMute = false;
                  });
                }
              },
            ),
          )
        ),
      ),
      builder: (_, bool showVolume, child) {
        return Container(
          decoration: BoxDecoration(
            color: showVolume ? kBackgroundColor.withOpacity(0.8) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              IconButton(
                icon: Icon( 
                  isMute ? Icons.volume_off_outlined : Icons.volume_up_outlined,
                  size: kIconSize,
                  color: kIconColor,
                ),
                onPressed: () => FeedManager.instance.changeShowVolumeStatus(widget.feedId),
              ),
              showVolume ? child! : const SizedBox(),
            ],
          ),
        );
      }
    );
  }


  changeState() {
    if(VideoPlayerManager.instance.isMute){
      VideoPlayerManager.instance.unmuteAll();
    } else {
      VideoPlayerManager.instance.muteAll();
    }
    setState(() {});
  }
}