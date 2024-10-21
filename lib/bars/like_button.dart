import 'package:flutter/material.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';


/// Like Button, if the Footbar.updateLikeButton change the ValueListenableBuilder update the button 
/// and recalculate the function isMediaLiked becouse it means that the feed has been scrolled and
/// the image is changes. I used setState to update the button on other conditions.
class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.assets});

  final List<AssetEntity?> assets;

  static ValueNotifier<int> reloadLikeButton = ValueNotifier<int>(0);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {

  bool isLiked = false;
  bool isReadyToLike = false;
  

  void isMediaLiked() async{
      isReadyToLike = false;
      if(corrIndx != null && widget.assets.isNotEmpty && widget.assets[corrIndx!] != null){
        String id = widget.assets[corrIndx!]!.id;
        /// Id media is in the database than is liked
        isLiked = await likeAssetsDb.existMedia(id);
        setState(() { isReadyToLike = true;});
      }
  }

  @override 
  void initState() {
    isMediaLiked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
    valueListenable: LikeButton.reloadLikeButton, 
    child: IconButton( 
        icon: isLiked ?
        const Icon(Icons.favorite        , size: kIconSize, color: Colors.red,) :
        const Icon(Icons.favorite_outline, size: kIconSize, color: kIconColor,),
        onPressed: () {
          if(isReadyToLike){
            AssetEntity? currAsset = widget.assets[corrIndx!];
            if(currAsset != null){
              if(isLiked) {
                likeAssetsDb.removeMedia(currAsset.id);
              }
              else{
                likeAssetsDb.addMedia(currAsset);
              }
              setState(() {isLiked = !isLiked;});
            }
            else{
              print("[INFO] Image not ready, please wait.");
            }
          }
          else {
            print("[WARN] Image not found!");
          }
        },
      ),
    builder: (BuildContext context, int value, Widget? child) {      
      isMediaLiked();
      return child!;
    }
    );  
  }
}