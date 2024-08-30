import 'package:flutter/material.dart';
import 'package:gallery_tok/globals.dart';

class Footbar extends StatelessWidget {
  const Footbar({
    super.key, 
    required this.isMediaLiked, 
    required this.likeMedia, 
    required this.deleteMedia, 
    required this.shareMedia, 
    required this.gotoAccount, 
  });
  
  static const iconSize = 25.0;
  static const fbHight = 60.0;
  static const iconColor = Colors.white;

  final bool isMediaLiked;
  final Function likeMedia;
  final Function shareMedia;
  final Function deleteMedia;
  final Function gotoAccount;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: Footbar.fbHight,
          color: thirdColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: isMediaLiked ?
                  const Icon(Icons.favorite        , size: Footbar.iconSize, color: Colors.red,) :
                  const Icon(Icons.favorite_outline, size: Footbar.iconSize, color: Footbar.iconColor,),
                onPressed: () => likeMedia(),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: Footbar.iconSize, color: Footbar.iconColor,), 
                onPressed: () => shareMedia(),      
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: Footbar.iconSize, color: Footbar.iconColor,), 
                onPressed: () => gotoAccount(),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: Footbar.iconSize, color: Footbar.iconColor,), 
                onPressed: () => deleteMedia(),
              ),
            ],
          ),
        ),
    );
  }
}

