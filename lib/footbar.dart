import 'package:flutter/material.dart';
import 'package:gallery_tok/account.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/libraries/permission.dart';
import 'package:gallery_tok/like_button.dart';
import 'package:photo_manager/photo_manager.dart';

class Footbar extends StatelessWidget {
  const Footbar({super.key, this.assetsList});

  final List<AssetEntity?>? assetsList;
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
              LikeButton(assetsList: assetsList,),
              
              // Share Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () async {
                  //if(!(await _getStorageAccess())) return;
                  if(corrIndx != null) SbroImage.shareMedia(assets[corrIndx!]);
                },      
              ),
              // Account Button
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () {
                  if(vpController != null){
                    vpController!.pause();
                  }
                  /// TODO: do this shaisse better
                  /// Notify the feed to put the pause icon
                  Feed.realoadFeed.value = true;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Account())
                  );
                },
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: kIconSize, color: kIconColor,), 
                onPressed: () {
                  //likedMedias.drop();
                  SbroImage.moveToTrash();
                  /// Per ora lo rimuoviamo direttamente. 
                  /// In futuro questa funzione verrà chiamata solo dalla pagina del cestino.
                  if(corrIndx != null && deleteImageForReal) SbroImage.deleteAsset(assets[corrIndx!]);
                },
              ),
            ],
          ),
        ),
    );
  }

   Future<bool> _getStorageAccess() async {
    switch (await SbroPermission.getStoragePermission()) {

      case PermissionsTypes.granted:
          // I need to upload all media first
          return true;       

      case PermissionsTypes.permanentlyDenied: 
          // TODO: pop a warning box saying "Go to settings and give the needed ..."
          print("Permission to storage is permanentlyDenied");
          return false;
          
      default:
        // TODO: maybe add a warnig banner here to
        _getStorageAccess();
        return false;
    }
  }
}

