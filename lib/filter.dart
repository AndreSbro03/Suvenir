import 'package:flutter/material.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/media_manager.dart';
import 'package:suvenir/libraries/saved_data.dart';
import 'package:suvenir/libraries/styles.dart';

/// Welcome to the app settings page. Here for now you can only chose what folders do you 
/// want to see in the app.
class Filter extends StatefulWidget {
  const Filter({super.key, required this.assets});

  final List<AssetEntity?> assets;
  static Map<String, bool> validPathsMap = {};
  static int savedAssets = 50;

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {

  @override
  Widget build(BuildContext context) {
    double rapidButtonsZoneHeight = getHeight(context) * 0.1;
    
    Widget pageContent = const Placeholder();

    pageContent = ValueListenableBuilder(
      valueListenable: isFoldersReady, 
      builder: (BuildContext context, bool value, Widget? child) {
        /// When the folders are ready we update the widget
        if(value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
    
              /// Fast selection buttons
    
              SizedBox(
                height: rapidButtonsZoneHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      
                      /// Select All button
                      GestureDetectorTextButton(
                        w: getWidth(context) * 0.3, 
                        h: getHeight(context), 
                        text: const Text("Select All", style: kNormalStyle,), 
                        color: kPrimaryColor,
                        onTap: () {
                          setState(() {
                            Filter.validPathsMap.forEach((K, _) {
                              Filter.validPathsMap[K] = true;
                            });
                          });
                        },
                      ), 
    
                      /// Deselect All button
                      GestureDetectorTextButton(
                        w: getWidth(context) * 0.3, 
                        h: getHeight(context), 
                        text: const Text("Deselect All", style: kNormalStyle,), 
                        color: kPrimaryColor,
                        onTap: () {
                          setState(() {
                            Filter.validPathsMap.forEach((K, _) {
                              Filter.validPathsMap[K] = false;
                            });
                          });
                        },
                      ), 
                  
                    ],
                  ),
                ),
              ),
    
              /// Folders list
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListView.builder(
                    itemCount: Filter.validPathsMap.length,
                    /*prototypeItem: ListTile(
                      title: Text(widget.paths.first.name),
                    ),*/
                    itemBuilder: (_, index) {
                      String corrPath = Filter.validPathsMap.keys.elementAt(index);
                      bool isCheck = Filter.validPathsMap[corrPath]!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: getWidth(context) * 0.70,
                            child: Text(corrPath , style: kNormalStyle,)
                          ),                        
                          Checkbox(
                            value: isCheck, 
                            checkColor: kContrColor,
                            activeColor: kSecondaryColor,
                            onChanged: (_) {
                              setState(() {
                                  Filter.validPathsMap[corrPath] = !isCheck;
                              });
                            }
                          ),
                        ],
                      );
                    }
                    ),
                ),
              ),
    
              /// Apply button
    
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: GestureDetectorTextButton(
                  w: getWidth(context) * 0.8,
                  h: getHeight(context) * 0.07,
                  text: const Text( "Apply", style: kH2Style,),
                  color: kPrimaryColor,
                  onTap: (){
    
                    /// Create new feed
                    widget.assets.clear();
                    widget.assets.addAll(SbroMediaManager.getValidPathAssetsList(folders, Filter.validPathsMap));
                    widget.assets.shuffle();  

                    int feedLen = widget.assets.length;     
                    print("[INFO] New number of assets in feed: $feedLen");   

                    /// Save [Filter.savedAssets] random assets in the db for next time loading
                    savedAssetsDb.removeAllRows().then( (_) => savedAssetsDb.addRandomMedias(widget.assets, Filter.savedAssets));
                    
                    /// Save current filter not validPath
                    List<String> resultList = Filter.validPathsMap.entries
                        .where((entry) => !entry.value) // Filter only false value
                        .map((entry) => entry.key)     // Transform elements in key
                        .toList();
                    SavedData.instance.setValidPaths(resultList);                     
    
                    /// Retrun to feed
                    Navigator.of(context).pop(true);
                  },
                ),
              )
            ],
          );
        }
        else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.all(kDefPadding * 2),
                  child: Text("Loading folders...", style: kDescriptionStyle,),
                )
              ],
            ),
          );
        }
      }
    );

    return Scaffold(
      appBar: AppBar(
        title:  const Text("Select Folders", style: kH2Style,),
        backgroundColor: kBackgroundColor,
        foregroundColor: kContrColor,
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: pageContent
      ),
    );
  }
}

class GestureDetectorTextButton extends StatelessWidget {
  const GestureDetectorTextButton({
    super.key, 
    required this.w, 
    required this.h, 
    required this.text, 
    required this.color, 
    required this.onTap,
  });

  final double w;
  final double h;
  final Text text;
  final Color color; 
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          //border: Border.all( color: Colors.amber, width: 2.0,)
        ),
        child: Center(
          child: text,
        ),
      ),
    );
  }
}