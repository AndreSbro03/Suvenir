import 'package:flutter/material.dart';
import 'package:gallery_tok/appbar.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/footbar.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.assetsList});

  final List<AssetEntity?> assetsList;

  @override
  Widget build(BuildContext context) {
    assets = assetsList;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          /// Level 0: (background) 
          ///   The feed once the permission are granted and the medias are loaded.
          ///   Circular progress indicator instead.
          Feed(assetsList: assetsList),
      
          /// Level 1: (Appbar and Footbar)
          const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Appbar:
              ///   consist in the app title and the settings IconButton.
              SbroAppBar(),
        
              /// Footbar:
              ///   consist in a list of icons.
              Footbar(),
            ],
          )
      
          /// Level 2: (Warnings Box)
      
        ]
      ),
    );
  }
}