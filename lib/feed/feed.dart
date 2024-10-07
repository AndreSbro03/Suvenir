import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/feed/image_view.dart';
import 'package:gallery_tok/feed/video_view.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/bars/like_button.dart';
import 'package:photo_manager/photo_manager.dart';

class Feed extends StatelessWidget {
  const Feed(
    {super.key, required this.assets, required this.feedController,}
  );

  final List<AssetEntity?> assets;
  final PageController feedController;

  /// Every @modIdxUpdate medias the feed check if the next @numNextUpdate medias are valid. (Not in forbidden folders)
  static int modIdxUpdate = 15;
  static int numNextUpdate = modIdxUpdate + 5;

  @override
  Widget build(BuildContext context) {                   

    return Column(
      children: [                 
        SizedBox(
          height: getHeight(context),
          child: 
          /// Here we make sure that if the assets list is modified we reload all the Feed
          PageView.builder(
              controller: feedController,
              onPageChanged: (newIdx) {
                corrIndx = newIdx;
                print(corrIndx);
                // Here you can insert code that notify all other widget that the media is changed
                LikeButton.reloadLikeButton.value++;
              },
              scrollDirection: Axis.vertical,
              itemCount: assets.length,
              itemBuilder: (_, index) {
                
                if (assets[index] == null){ 
                  return const Center(child: Text("Image unavailable.\n Might be deleted", style: kNormalStyle,),);
                }
                else {      
            
                  /// Update next @Feed.numNextUpdate medias
                  if(index % modIdxUpdate == 0 && index != 0) {
                    SbroImage.updateAssets(assets, index, numNextUpdate);
                  }
            
                  AssetEntity ae = assets[index]!;
            
                  if(ae.type == AssetType.video) {
                    return VideoView(video: ae);
                  }
                  else { 
                    return ImageView(image: ae);
                  }

              } 
            }
          ),  
        )
      ]
    );
  }
}