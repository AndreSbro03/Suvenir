import 'package:flutter/material.dart';
import 'package:suvenir/bars/volume.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/istances/video_player_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:suvenir/filter.dart';
import 'package:photo_manager/photo_manager.dart';

class SbroAppBar extends StatelessWidget {
  const SbroAppBar({
    super.key, 
    required this.feedId, 
    required this.reload, 
    required this.assets, 
    required this.feedController, 
    required this.showInfoBox, 
  });

  final FeedId feedId;
  final VoidCallback reload;
  final List<AssetEntity?> assets;
  final PageController feedController;
  final ValueNotifier<bool> showInfoBox;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Title
            const Text(
              appName,
              style: kH1Style,
            ),

            const Expanded(child: SizedBox()),

            VolumeIconButton(feedId: feedId,),

            IconButton(
              onPressed: () {
                showInfoBox.value = !showInfoBox.value;
              },
              icon: const Icon(Icons.info_outline, size: kIconSize, color: kIconColor,),
            ),

            /// Filter Button only in the main feed
            (feedId == FeedId.main) ? 
            IconButton(
              onPressed: () async {
                /// If a video is going we stop it before going to the filter
                VideoPlayerManager.instance.pauseAll();

                bool? modified = await Navigator.of(context).push(
                   MaterialPageRoute(builder: (_) => Filter(assets: assets))
                );

                /// If something has changed in the settings we reload the feed
                if(modified != null && modified) {
                  /// Return to first item.
                  /// If the feed doesn't exist we can't tell the feedController to jump to 
                  /// a page becaouse the controller is not attached to any PageView.
                  corrIndx = 0;
                  feedController.jumpToPage(0);

                  reload();
                }
              }, 
              icon: Image.asset("assets/filter_100.png", width: kIconSize, height: kIconSize, color: kIconColor),
              ) : 
              const SizedBox(),
          ],
        ),
      ),
    );
  }
}