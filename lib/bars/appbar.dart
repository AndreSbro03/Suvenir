import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/settings.dart';
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

            /// Settings Button
            IconButton(
              onPressed: () async {
                /// If a video is going we stop it before going to the settings
                /// TODO: Notify the feed to reload so we can show the Play icon in the video
                /// if(vpController != null) vpController!.pause();

                /// Here we check if the feedController is attached to a PageView and we save the result.
                bool existsFeed = assets.isNotEmpty;

                bool modified = await Navigator.of(context).push(
                   MaterialPageRoute(builder: (_) => Settings(assets: assets))
                );

                /// If something has changed in the settings we reload the feed
                if(modified) {
                  /// If the feed doesn't exist we can't tell the feedController to jump to 
                  /// a page becaouse the controller is not attached to any PageView.
                  if(existsFeed){
                    feedController.jumpToPage(0);
                  }
                  reload();
                }
              }, 
              icon: const Icon(Icons.settings_outlined, size: kIconSize, color: kIconColor),
              )
          ],
        ),
      ),
    );
  }
}