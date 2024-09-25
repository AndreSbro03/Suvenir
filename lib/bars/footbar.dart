import 'package:flutter/material.dart';
import 'package:gallery_tok/account.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/bars/like_button.dart';
import 'package:gallery_tok/libraries/permission.dart';
import 'package:photo_manager/photo_manager.dart';

class Footbar extends StatelessWidget {
  const Footbar({super.key, this.assetsList, this.isTrashFeed = false});

  final List<AssetEntity?>? assetsList;
  final bool isTrashFeed;

  static const fbHight = 60.0;

  @override
  Widget build(BuildContext context) {

    List<AssetEntity?> _assetsList = (assetsList == null) ? assets : assetsList!;

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
                const Text("ciao", style: kNormalStyle,) :
                LikeButton(assetsList: assetsList,),
              
              // Share Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () async {
                  //if(!(await _getStorageAccess())) return;
                  if(corrIndx != null) SbroImage.shareAsset(_assetsList[corrIndx!]);
                },      
              ),
              // Home Button
              IconButton(
                icon: Icon(
                  /// If assetsList is null that means that we are in the home page
                  (assetsList == null) ? Icons.home_rounded : Icons.home_outlined, 
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
              isTrashFeed ? 
              const Text("mamma", style: kNormalStyle) :
              IconButton(
                icon: const Icon(Icons.delete_outline, size: kIconSize, color: kIconColor,), 
                onPressed: () async {

                  /// Request permission
                  if(await SbroPermission.isStoragePermissionGranted()){

                    SbroImage.moveToTrash(_assetsList[corrIndx!]!);
                    /// Update the homePageFeed
                    _assetsList[corrIndx!] = null;
                    homeFeedController.nextPage(duration: const Duration(milliseconds: Feed.scrollDurationMilliseconds), curve: Curves.easeInOut);
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

