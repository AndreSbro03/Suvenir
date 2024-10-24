import 'package:flutter/material.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:suvenir/settings.dart';
import 'package:photo_manager/photo_manager.dart';

class SbroAppBar extends StatelessWidget {
  const SbroAppBar({
    super.key, required this.reload, required this.assets, required this.feedController, 
  });

  final VoidCallback reload;
  final List<AssetEntity?> assets;
  final PageController feedController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Title
            const Text(
              appName,
              style: kH1Style,
            ),

            const Expanded(child: SizedBox()),

            /// Settings Button only in the main feed
            (assets.hashCode == mainFeedHash) ? 
            IconButton(
              onPressed: () async {
                /// If a video is going we stop it before going to the settings
                if(lastVideoView != null) {
                  lastVideoView!.currentState?.pauseVideo();
                }

                bool? modified = await Navigator.of(context).push(
                   MaterialPageRoute(builder: (_) => Settings(assets: assets))
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
              icon: const Icon(Icons.settings_outlined, size: kIconSize, color: kIconColor),
              ) : 
              const SizedBox(
                height: kIconSize,
                width: kIconSize,
              ),
          ],
        ),
      ),
    );
  }
}