import 'package:flutter/material.dart';
import 'package:suvenir/account/account.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/istances/video_player_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/media_manager.dart';
import 'package:suvenir/bars/like_button.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:suvenir/libraries/trash.dart';

class Footbar extends StatelessWidget {
  const Footbar({
    super.key, 
    required this.id,
    required this.assets, 
    required this.reload, 
    });

  final FeedId id;
  final List<AssetEntity?> assets;
  final Function reload;

  static const fbHight = 60.0;

  bool _isAssetValid(){
    return (corrIndx != null && assets[corrIndx!] != null);
  }

  String _popAssetFromFeed(){
    String id = assets[corrIndx!]!.id;  
    assets[corrIndx!] = null;
    /// Pause a video if it is loading
    VideoPlayerManager.instance.pauseAll();
    reload();
    return id;
  }

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
                id == FeedId.trash ?
                IconButton(
                  icon: const Icon(Icons.restore_from_trash_rounded, size: kIconSize, color: kIconColor,), 
                  onPressed: () {
                    if(_isAssetValid()) {
                      Trash.restoreAssetFromTrash(_popAssetFromFeed());
                    }
                    else{
                      print("[WARN] Trying to restore a null asset!");
                    }                
                  },
                ) :
              LikeButton(assets: assets,),
              
              // Share Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () async {
                  //if(!(await _getStorageAccess())) return;
                  if(corrIndx != null) SbroMediaManager.shareAsset(assets[corrIndx!]);
                },      
              ),
              // Home Button
              IconButton(
                icon: Icon(
                  /// If assest is origianAssets then we are in the home page
                  (assets.hashCode == mainFeedHash) ? Icons.home_rounded : Icons.home_outlined, 
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
                  /// Pause the video if there is one
                  VideoPlayerManager.instance.pauseAll();

                  /// Call the account page
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Account())
                  );

                  // reload();
                },
              ),

              /// Delete Button:
              /// if pressed we remove forever the current asset from device and we remove the id of the asset from the 
              /// trashed db.
              id == FeedId.trash ? 
              IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, size: kIconSize, color: kIconColor,), 
                  onPressed: () async {
                    if(_isAssetValid()){
                      String id = _popAssetFromFeed();
                      SbroMediaManager.deleteAssetFromId(id);
                      trashAssetsDb.removeMedia(id);
                    }
                    else{
                      print("[WARN] Trying to remove asset null!");
                    }
                  },

                ) :
              IconButton(
                icon: const Icon(Icons.delete_outline, size: kIconSize, color: kIconColor,), 
                onPressed: () async {

                  if(_isAssetValid()){
                    AssetEntity ae = assets[corrIndx!]!;
                    /// We immediatly notify the feed to reload than we proceed to move the asset. Because, if 
                    /// we invert the two, from the tap on the icon to the reload of the page there is a bit of 
                    /// time that seems lag.
                    _popAssetFromFeed();
                    if(await Trash.moveToTrash(ae) > 0){
                      print("[INFO] Impossible to move the file to trash!");
                    }
                  }
                },
              ),
            ],
          ),
        ),
    );
  }
}

