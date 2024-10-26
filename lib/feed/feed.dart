import 'package:flutter/material.dart';
import 'package:suvenir/bars/footbar.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/feed/image_view.dart';
import 'package:suvenir/feed/video_view.dart';
import 'package:suvenir/libraries/image.dart';
import 'package:suvenir/bars/like_button.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';

class Feed extends StatefulWidget {
  const Feed(
    {super.key, required this.assets, required this.feedController, required this.showInfoBox,}
  );

  final List<AssetEntity?> assets;
  final PageController feedController;
  final ValueNotifier<bool> showInfoBox;

  /// Every @modIdxUpdate medias the feed check if the next @numNextUpdate medias are valid. (Not in forbidden folders or null)
  static int modIdxUpdate = 15;
  /// It is bigger so that I can be sure that every @modIdxUpdate the alghoritm has time to parse the next assets.
  static int numNextUpdate = modIdxUpdate * 2; 

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  
  @override
  Widget build(BuildContext context) {                 

    print("[INFO] Total assets in feed: ${widget.assets.length}");

    return Column(
      children: [                 
        SizedBox(
          height: getHeight(context),
          child: 
          widget.assets.isNotEmpty ?
          /// Here we make sure that if the assets list is modified we reload all the Feed
          Stack(
            children: [
              
              PageView.builder(
                  /// Attach the feedController to the PageView
                  controller: widget.feedController,
                  onPageChanged: (newIdx) {
                    corrIndx = newIdx;
                    // print(corrIndx);
                    /// On scroll we reset the infoBox 
                    widget.showInfoBox.value = false;
                    /// Here you can insert code that notify all other widget that the media is changed
                    LikeButton.reloadLikeButton.value++;
                  },
                  scrollDirection: Axis.vertical,
                  itemCount: widget.assets.length,
                  itemBuilder: (_, index) {
                    
                    if (widget.assets[index] == null){ 
                      return const Center(child: 
                        Text("Image unavailable.\n Might be moved or deleted.", style: kNormalStyle, textAlign: TextAlign.center,),
                      );
                    }
                    else {      
                
                      /// Update next @Feed.numNextUpdate medias
                      if(index % Feed.modIdxUpdate == 0 && index != 0) {
                        SbroImage.updateAssets(widget.assets, index, Feed.numNextUpdate);
                      }
                
                      AssetEntity ae = widget.assets[index]!;
                
                      if(ae.type == AssetType.video) {
                        final GlobalKey<VideoViewState> videoViewKey = GlobalKey<VideoViewState>();
                        /// Alising vw -> videoView
                        lastVideoView = videoViewKey;
                        return VideoView(key: videoViewKey, video: ae);
                      }
                      else { 
                        return ImageView(image: ae);
                      }
              
                  } 
                }
              ),
              /// Info box
              ValueListenableBuilder(
                valueListenable: widget.showInfoBox, 
                builder: (BuildContext context, bool showInfoBox, Widget? child) {
                  if(showInfoBox){
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
          
                        if (corrIndx != null && widget.assets[corrIndx!] != null) 
                          InfoBox(asset: widget.assets[corrIndx!]!) 
                        else 
                          const Text("[ERR] Current index is Nan!", style: kNormalStyle),
          
                        const SizedBox(
                          height: Footbar.fbHight,
                        )
                      ]
                    );
                  }
                  return const SizedBox();
                },
              )
            ],
          ) :
          const Center(child: Text("No media avaiable!",style: kNormalStyle,),),
        )
      ]
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key, required this.asset,

  });
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(2 * kDefPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Modified date: ${removeClockFromDate(asset.modifiedDateTime)}", style: kNormalStyle,),
            /// Cration date usually is wrong and is more recent than the modifiedDateTime
            /// Text("Creation date: ${removeClockFromDate(asset!.createDateTime)}", style: kNormalStyle,),
            Text("Source: ${asset.relativePath}", style: kNormalStyle,),
          ],
        ),
      )
      );
  }
}