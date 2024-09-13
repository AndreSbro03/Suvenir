import 'package:flutter/material.dart';
import 'package:gallery_tok/account.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';

class Footbar extends StatelessWidget {
  const Footbar({
    super.key
  });
  
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
              IconButton(
                icon: false ?
                  const Icon(Icons.favorite        , size: kIconSize, color: Colors.red,) :
                  const Icon(Icons.favorite_outline, size: kIconSize, color: kIconColor,),
                onPressed: () {},
              ),
              // Share Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: kIconSize, color: kIconColor,), 
                onPressed: () {
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
}

