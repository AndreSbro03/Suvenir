import 'package:flutter/material.dart';
import 'package:gallery_tok/account.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/bars/like_button.dart';
import 'package:photo_manager/photo_manager.dart';

class Footbar extends StatelessWidget {
  const Footbar({super.key, this.assetsList});

  final List<AssetEntity?>? assetsList;
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
              IconButton(
                icon: const Icon(Icons.delete_outline, size: kIconSize, color: kIconColor,), 
                onPressed: () {
                  SbroImage.moveToTrash(_assetsList[corrIndx!]!);
                  /// Update the homePageFeed
                  _assetsList[corrIndx!] = null;
                  homeFeedController.nextPage(duration: const Duration(milliseconds: Feed.scrollDurationMilliseconds), curve: Curves.easeInOut);
                  /// Per ora lo rimuoviamo direttamente. 
                  /// In futuro questa funzione verrà chiamata solo dalla pagina del cestino.
                  if(corrIndx != null && deleteImageForReal) SbroImage.deleteAsset(_assetsList[corrIndx!]);
                },
              ),
            ],
          ),
        ),
    );
  }

}

