import 'package:flutter/material.dart';
import 'package:gallery_tok/account.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/bars/like_button.dart';
import 'package:gallery_tok/libraries/permission.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class Footbar extends StatelessWidget {
  const Footbar({
    super.key, 
    required this.assets, 
    this.isTrashFeed = false, 
    required this.reload,
    this.vp,
    });

  final List<AssetEntity?> assets;
  final VideoPlayerController? vp;
  final bool isTrashFeed;
  final Function reload;

  static const fbHight = 60.0;

  @override
  Widget build(BuildContext context) {

    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: Footbar.fbHight,
          color: kThirdColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Like Button
               isTrashFeed ?
                IconButton(
                  icon: const Icon(Icons.restore_from_trash_rounded, size: kIconSize, color: kIconColor,), 
                  onPressed: () {






                    
                  },
                ) :
              LikeButton(assets: assets,),
              
              // Share Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () async {
                  //if(!(await _getStorageAccess())) return;
                  if(corrIndx != null) SbroImage.shareAsset(assets[corrIndx!]);
                },      
              ),
              // Home Button
              IconButton(
                icon: Icon(
                  /// If assest is origianAssets then we are in the home page
                  (assets == originalAssets) ? Icons.home_rounded : Icons.home_outlined, 
                  size: kIconSize, color: kIconColor,), 
                onPressed: () {
                  print("[INFO] Retourning to the HomePage!");
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },      
              ),
              // Account Button
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () {
                  if(vp != null){
                    vp!.pause();
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Account())
                  );

                  reload();
                },
              ),

              /// Delete Button:
              /// if pressed we remove forever the current asset from device and we remove the id of the asset from the 
              /// trashed db.
              isTrashFeed ? 
              IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, size: kIconSize, color: kIconColor,), 
                  onPressed: () async {
                    if(corrIndx != null && assets[corrIndx!] != null){
                        /// TODO: ask to confirm
                        String id = assets[corrIndx!]!.id;
                        SbroImage.deleteAsset(assets[corrIndx!]);
                        trashAssetsDb.removeMedia(id);
                        assets[corrIndx!] = null;
                        reload();
                    }
                    else{
                      print("[ERR] Trying to remove asset null!");
                    }
                  },

                ) :
              IconButton(
                icon: const Icon(Icons.delete_outline, size: kIconSize, color: kIconColor,), 
                onPressed: () async {

                  /// Request permission
                  if(await SbroPermission.isStoragePermissionGranted()){

                    SbroImage.moveToTrash(assets[corrIndx!]!);
                    /// Update the homePageFeed
                    assets[corrIndx!] = null;
                    reload();
                  }
                  else{
                    print("[INFO] Permission denied");
                  }
                },
              ),
            ],
          ),
        ),
    );
  }

}

