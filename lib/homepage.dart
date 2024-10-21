import 'package:flutter/material.dart';
import 'package:suvenir/bars/appbar.dart';
import 'package:suvenir/feed/feed.dart';
import 'package:suvenir/bars/footbar.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/image.dart';
import 'package:photo_manager/photo_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key, 
    required this.assets, 
    this.feedController, 
    this.isTrashFeed = false
  });

  final List<AssetEntity?> assets;
  final PageController? feedController;
  
  /// If true the footbar instead of the like and trash button will have a restore and delete button
  final bool isTrashFeed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final PageController _feedController;

  void _loadFeed() async {

    /// If the feed is the trashFeed we can't update the assets because they are all in a non valid folder
    if(!widget.isTrashFeed){
      int until = Feed.numNextUpdate;
      if(corrIndx != null){
        until += corrIndx!;
      }
      print("[INFO] Reloading!");
      await SbroImage.updateAssets(widget.assets, 0, until);
    }
    
    setState(() {
    });
  }

  @override 
  void initState(){
    _loadFeed();
    if(widget.feedController == null){
      _feedController = PageController();
    } else {
      _feedController = widget.feedController!;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: 
      Stack(
        children: [
          /// Level 0: (background) 
          ///   The feed once the permission are granted and the medias are loaded.
          ///   Circular progress indicator instead.
          Feed(assets: widget.assets, feedController: _feedController,),
          /// Level 1: (Appbar and Footbar)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Appbar:
              ///   consist in the app title and the settings IconButton.
              SbroAppBar(assets: widget.assets, reload: _loadFeed, feedController: _feedController, ),
        
              /// Footbar:
              ///   consist in a list of icons.
              Footbar(assets: widget.assets, isTrashFeed: widget.isTrashFeed, reload: _loadFeed,),
            ],
          )
      
          /// Level 2: (Warnings Box)
      
        ]
      ),
    );
  }
}