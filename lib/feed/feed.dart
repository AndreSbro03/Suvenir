import 'package:flutter/material.dart';
import 'package:suvenir/bars/footbar.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/istances/video_player_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/feed/image_view.dart';
import 'package:suvenir/feed/video_view.dart';
import 'package:suvenir/libraries/media_manager.dart';
import 'package:suvenir/bars/like_button.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';

class Feed extends StatefulWidget {
  const Feed(
    {super.key, required this.assets, required this.feedController, required this.showInfoBox, required this.id,}
  );

  final FeedId id;
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
  bool scrollable = true;
  final Set<int> _activePointers = {};
  
  @override
  Widget build(BuildContext context) {                 

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
                  physics: scrollable ? null : const NeverScrollableScrollPhysics(),
                  onPageChanged: (newIdx) {
                    corrIndx = newIdx;
                    /// Pause old videos exept the corrent one that will be played (if it is a video).
                    String? idCorr = (widget.assets[newIdx] == null) ? null : widget.assets[newIdx]!.id;
                    VideoPlayerManager.instance.keepPlayId(VideoPlayerManager.instance.pauseAll(idCorr));

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
                        SbroMediaManager.updateAssets(widget.assets, index, Feed.numNextUpdate, widget.id).then( (removed) {
                          if(removed > 0) FeedManager.instance.reloadFeed(widget.id); 
                        });
                      }
                
                      AssetEntity ae = widget.assets[index]!;
                
                      if(ae.type == AssetType.video) {
                        return VideoView(video: ae);
                      }
                      else { 
                        return Listener(
                          onPointerDown: (event) {
                            // When a finger is placed on the screen, add its pointer to the set
                            _activePointers.add(event.pointer);
                            if(_activePointers.length >= 2){ 
                              setState(() {
                                scrollable = false;
                              });
                            }

                            /// If user touch the screen and we want disable something put it here
                            FeedManager.instance.hideVolume(widget.id); /// Hide volume bar

                            /// print("[INFO] Pointer down. Active pointers: ${_activePointers.length}");
                          },
                          onPointerUp: (event) {
                            // When a finger is lifted, remove its pointer from the set
                            _activePointers.remove(event.pointer);
                            if(_activePointers.length < 2){ 
                              setState(() {
                                scrollable = true;
                              });
                            }
                            /// print("[INFO] Pointer up. Active pointers: ${_activePointers.length}");
                          },
                          child: ImageView(image: ae)
                          );
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
                          const Text("Current index is Nan!", style: kNormalStyle),
          
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

class InfoBox extends StatefulWidget {
  const InfoBox({
    super.key, required this.asset,

  });
  final AssetEntity asset;

  @override
  State<InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {

  String? originalPath;
  String? addedDate;

  void getTrashedData() async {
    if(await trashAssetsDb.existMedia(widget.asset.id)){
      originalPath = await trashAssetsDb.getAssetOldPath(widget.asset.id);
      addedDate = await trashAssetsDb.getAssetDeletionTime(widget.asset.id);
      setState(() {});
    }
  }

  @override
  void initState() {
    // getTrashedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(2 * kDefPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Modified date: ${removeClockFromDate(widget.asset.modifiedDateTime)}", style: kNormalStyle,),
            /// Cration date usually is wrong and is more recent than the modifiedDateTime
            /// Text("Creation date: ${removeClockFromDate(asset!.createDateTime)}", style: kNormalStyle,),
            Text("Source: ${widget.asset.relativePath}", style: kNormalStyle,),
          ],
        ),
      )
      );
  }
}