import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';


/// Like Button, if the Footbar.updateLikeButton change the ValueListenableBuilder update the button 
/// and recalculate the function isMediaLiked becouse it means that the feed has been scrolled and
/// the image is changes. I used setState to update the button on other conditions.
class LikeButton extends StatefulWidget {
  const LikeButton({super.key, this.assetsList});

  final List<AssetEntity?>? assetsList;

  static ValueNotifier<bool> reloadLikeButton = ValueNotifier<bool>(false);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {

  bool isLiked = false;
  bool isReadyToLike = false;
  List<AssetEntity?> assetsList = [];
  

  void isMediaLiked() async{
      isReadyToLike = false;
      isLiked = await likedMedias.existMedia((corrIndx != null) ? assetsList[corrIndx!] : null);
      setState(() { isReadyToLike = true;});
  }

  @override 
  void initState() {
    assetsList = (widget.assetsList != null) ? widget.assetsList! : assets;
    isMediaLiked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
    valueListenable: LikeButton.reloadLikeButton, 
    builder: (BuildContext context, bool value, Widget? child) {
      /// Here check if the media is Liked only if the updateLikeButton value is changed.
      if(LikeButton.reloadLikeButton.value){
        isMediaLiked();
        LikeButton.reloadLikeButton.value = false;
      }
      return IconButton( 
        icon: isLiked ?
        const Icon(Icons.favorite        , size: kIconSize, color: Colors.red,) :
        const Icon(Icons.favorite_outline, size: kIconSize, color: kIconColor,),
        onPressed: () {
          if(isReadyToLike){
            AssetEntity? currAsset = assets[corrIndx!];
            if(isLiked) {
              likedMedias.removeMedia(currAsset);
            }
            else{
              likedMedias.addMedia(currAsset);
            }
            setState(() {isLiked = !isLiked;});
          }
          else{
            print("[INFO] Image not ready, please wait.");
          }
        },
      );
    }
    );  
  }
}