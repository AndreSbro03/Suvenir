import 'package:flutter/material.dart';
import 'package:gallery_tok/bars/footbar.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/feed/image_view.dart';
import 'package:gallery_tok/feed/video_view.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/bars/like_button.dart';
import 'package:photo_manager/photo_manager.dart';

class Feed extends StatefulWidget {
  const Feed(
    {super.key, required this.assets, required this.feedController,}
  );

  final List<AssetEntity?> assets;
  final PageController feedController;

  /// Every @modIdxUpdate medias the feed check if the next @numNextUpdate medias are valid. (Not in forbidden folders)
  static int modIdxUpdate = 15;
  /// It is bigger so that I can be sure that every @modIdxUpdate the alghoritm has time to parse the next assets.
  static int numNextUpdate = modIdxUpdate * 2; 

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  
  bool _showInfo = false;

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
          GestureDetector(
            onLongPress: (){
              setState(() {
                _showInfo = true;
              });
            },
            onLongPressUp: () {
              setState(() {
                _showInfo = false;
              });
            },
            child: Stack(
              children: [
                
                PageView.builder(
                    /// Attach the feedController to the PageView
                    controller: widget.feedController,
                    onPageChanged: (newIdx) {
                      corrIndx = newIdx;
                      print(corrIndx);
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
                _showInfo ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (corrIndx != null) ?
                    InfoBox(asset: widget.assets[corrIndx!]) :
                    const Text("[ERR] Current index is Nan!", style: kNormalStyle),
                    const SizedBox(
                      height: Footbar.fbHight,
                    )
                  ],
                ) :
                const SizedBox(),
              ],
            ),
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
  final AssetEntity? asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${removeClockFromDate(asset!.createDateTime)}", style: kNormalStyle,),
            Text("Source: ${SbroImage.getAssetRelativePath(asset)}", style: kNormalStyle,),
          ],
        ),
      )
      );
  }
}