import 'package:flutter/material.dart';
import 'package:gallery_tok/bars/appbar.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/bars/footbar.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
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



  void reload(){
    int until = Feed.numNextUpdate;
    if(corrIndx != null){
      until += corrIndx!;
    }
    SbroImage.updateAssets(widget.assets, 0, until);
    setState(() {});
  }

  @override 
  void initState(){
    if(!widget.isTrashFeed){
      reload();
    }
    if(widget.feedController == null){
      _feedController = PageController();
    } else {
      _feedController = widget.feedController!;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    //print("Widget assets lenght: ${widget.assets.length}");
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
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
              SbroAppBar(assets: widget.assets, reload: reload, feedController: _feedController, ),
        
              /// Footbar:
              ///   consist in a list of icons.
              Footbar(assets: widget.assets, isTrashFeed: widget.isTrashFeed, reload: reload,),
            ],
          )
      
          /// Level 2: (Warnings Box)
      
        ]
      ),
    );
  }
}