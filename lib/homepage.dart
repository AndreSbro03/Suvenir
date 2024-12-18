import 'package:flutter/material.dart';
import 'package:suvenir/bars/appbar.dart';
import 'package:suvenir/feed/feed.dart';
import 'package:suvenir/bars/footbar.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/media_manager.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key, 
    required this.assets, 
    this.feedController, 
    required this.id,
  });

  final FeedId id;
  final List<AssetEntity?> assets;
  final PageController? feedController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final PageController _feedController;
  ValueNotifier<bool> showInfoBox = ValueNotifier<bool>(false); 

  void reloadFeedAssets() async {
    
    /// We need to disable the infoBox because the image might change
    showInfoBox.value = false;

    print("[INFO] Reloading!");
    int removed = await SbroMediaManager.updateAssets(widget.assets, corrIndx??0, Feed.numNextUpdate, widget.id);
    
    /// If nothing has changed we don't reload the feed
    if(removed > 0){
      FeedManager.instance.reloadFeed(widget.id);
    }
  }

  @override 
  void initState(){
    reloadFeedAssets();
    if(widget.feedController == null){
      _feedController = PageController(keepPage: true);
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
          ValueListenableBuilder(
            valueListenable: FeedManager.instance.getReloadFeedListener(widget.id),
            builder: (context, value, _) {
              print("[INFO] Feed reloaded!");
              return Feed(id: widget.id, assets: widget.assets, feedController: _feedController, showInfoBox: showInfoBox,);
            },
            ),
          /// Level 1: (Appbar and Footbar)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Appbar:
              ///   consist in the app title and the settings IconButton.
              SbroAppBar(feedId: widget.id, assets: widget.assets, reload: reloadFeedAssets, feedController: _feedController, showInfoBox: showInfoBox,),
        
              /// Footbar:
              ///   consist in a list of icons.
              Footbar(feedID: widget.id, assets: widget.assets, reload: reloadFeedAssets,),
            ],
          )
      
          /// Level 2: (Warnings Box)
      
        ]
      ),
    );
  }
}