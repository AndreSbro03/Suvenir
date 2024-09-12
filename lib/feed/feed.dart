import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/feed/image_view.dart';
import 'package:gallery_tok/feed/video_view.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/settings.dart';
import 'package:photo_manager/photo_manager.dart';

class Feed extends StatefulWidget {
  const Feed(
    {super.key, this.assetsList,}
  );

  final List<AssetEntity>? assetsList;

  /// Every @modIdxUpdate medias the feed check if the next @numNextUpdate medias are valid. (Not in forbidden folders)
  static int modIdxUpdate = 15;
  static int numNextUpdate = 50;

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  @override
  Widget build(BuildContext context) {

    // If there is not a custom list passed or if the list passed is empty we go with the global one
    bool isListGlobal = (widget.assetsList == null);
    if(!isListGlobal){
      isListGlobal = widget.assetsList!.isEmpty;
    }

    return Column(
      children: [              
        SizedBox(
          height: getHeight(context),
          child: PageView.builder(
            controller: feedController,
            onPageChanged: (newIdx) {
              corrIndx = newIdx;
              print(corrIndx);
              // Here you can insert code that notify all other widget that the media is changed
            },
            scrollDirection: Axis.vertical,
            itemCount: (isListGlobal) ? assets.length : widget.assetsList!.length,
            itemBuilder: (_, index) {
              
              if (assets[index] == null){ 
                return const Center(child: Text("Image unavailable", style: kNormalStyle,),);
              }
              else {      

                /// Update next @Feed.numNextUpdate medias
                if(index % Feed.modIdxUpdate == 0) {
                  SbroImage.updateAssets(index, Feed.numNextUpdate);
                }

                AssetEntity ae = isListGlobal ? assets[index]! : widget.assetsList![index];

                if(ae.type == AssetType.video) {
                  return VideoView(video: ae);
                }
                else { 
                  return ImageView(image: ae);
                }
              }
            }
          ) 
        ),  
      ]
    );
  }
}