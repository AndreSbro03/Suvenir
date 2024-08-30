import 'package:flutter/material.dart';
import 'package:gallery_tok/home_page/footbar.dart';
import 'package:gallery_tok/globals.dart';
import 'package:gallery_tok/media_manager/image.dart';
import 'package:gallery_tok/media_manager/image_view.dart';
import 'package:gallery_tok/media_manager/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

class Feed extends StatefulWidget {
  const Feed({
    super.key, 
    required this.readyToStart, 
    required this.pauseVideo,
    required this.showPermissionBox, 
    required this.gotoAccount, 
  });

  final bool readyToStart;
  final Wrapper<bool> pauseVideo;

  final Function showPermissionBox;
  final Function gotoAccount;

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  bool isMediaLiked() {
    return (corrIndx != null) ? likedIds.contains(assets[corrIndx!].id) : false;
  } 

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [              
        SizedBox(
          height: getHeight(context) - Footbar.fbHight,
          child: widget.readyToStart ? 
            PageView.builder(
              onPageChanged: (newIdx) {
                corrIndx = newIdx;
                setState(() {});
              },
              scrollDirection: Axis.vertical,
              itemCount: assets.length,
              itemBuilder: (_, index) {

                if(assets[index].type == AssetType.video) {
                  return VideoView(video: assets[index], pauseVideo: widget.pauseVideo,);
                }
                else { 
                  return ImageView( image: assets[index]);
                }
              }
            ) 
            :
            const Center(child: CircularProgressIndicator())

        ),
        Footbar(         
          isMediaLiked: isMediaLiked(),
          likeMedia: () {
            if (corrIndx != null) {
              String id = assets[corrIndx!].id;
              setState(() {
                if(isMediaLiked()){
                  print("Sto rimuovendo");
                  likedIds.remove(id);
                  SbroDatabase.instance.removeMedia(int.parse(id));
                }
                else {
                  print("Sto aggiungiendo");
                  likedIds.add(id);
                  SbroDatabase.instance.addMedia(int.parse(id), DateTime.now());
                }
              });
            }
          },
          shareMedia: () => SbroImage.shareMedia(assets[corrIndx!]), 
          deleteMedia: widget.showPermissionBox, 
          gotoAccount: widget.gotoAccount, 
        ),  
      ]
    );
  }
}