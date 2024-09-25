import 'package:flutter/material.dart';
import 'package:gallery_tok/bars/appbar.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/bars/footbar.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key, 
    this.assetsList, 
    this.feedController, 
    this.isTrashFeed = false
  });

  final List<AssetEntity?>? assetsList;
  final PageController? feedController;
  
  /// If true the footbar instead of the like and trash button will have a restore and delete button
  final bool isTrashFeed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          /// Level 0: (background) 
          ///   The feed once the permission are granted and the medias are loaded.
          ///   Circular progress indicator instead.
          Feed(assetsList: assetsList, feedController: feedController,),
          /// Level 1: (Appbar and Footbar)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Appbar:
              ///   consist in the app title and the settings IconButton.
              const SbroAppBar(),
        
              /// Footbar:
              ///   consist in a list of icons.
              Footbar(assetsList: assetsList, isTrashFeed: isTrashFeed),
            ],
          )
      
          /// Level 2: (Warnings Box)
      
        ]
      ),
    );
  }
}