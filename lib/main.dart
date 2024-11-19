import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suvenir/homepage.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/image.dart';
import 'package:suvenir/libraries/permission.dart';
import 'package:suvenir/filter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/saved_data.dart';
import 'package:suvenir/libraries/trash.dart';


/// Here we setup the application and require the gallery permission.
/// Once the user has provide that we start the feed. 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// Disable auto rotation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  Trash.cleanTrash();

  /// Remove bottom navigation bar
  /// await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool readyToGo = false;
  List<AssetEntity?> mainFeed = [];


  /// ```dart
  ///     1 - Search all folders in the phone.
  ///     2 - Remove the trashPath from the list.
  ///     3 - Create the validity map and set all values true.
  ///     4 - Return the List<AssetPathEntity?> founded.
  /// ```
  Future<List<AssetPathEntity?>> _getPathList() async {

    /// hasAll : false make sure to remove the "Recent" folder that contains copy of other assets present in other folders
    List<AssetPathEntity> apel = await PhotoManager.getAssetPathList(hasAll: false);

    List<String> folderNames = apel.map((asset) => asset.name).toList();

    // Convert to set to improve comparison
    Set<String> folderNamesSet = Set.from(folderNames);
    Set<String> invalidPathsSet = Set.from(await SavedData.instance.getInvalidPaths());

    Map<String, bool> resultMap = {};

    // If the item is in the invalidPathSet we want the value to be false
    for (String item in folderNamesSet) {
      resultMap[item] = !invalidPathsSet.contains(item);
    }

    Filter.validPathsMap.remove(Trash.trashPath);

    Filter.validPathsMap = resultMap;

    /// print("[INFO] Getting paths: ${Settings.validPathsMap.toString()}");

    return apel;
  }

  Future<void> _getFoldersFromGallery(List<AssetPathEntity?> apel) async {
    /// Parse directy, no error risk but solwer
    folders = await SbroImage.fetchAssetsByFolders(apel);
    /// originalAssets = SbroImage.getValidPathAssetsList(folders, Filter.validPathsMap);
    /// originalAssets.shuffle();
    
    /// print("[INFO] Loaded all ${originalAssets.length} images!");
  }

  void _quickLoadImage() async {
    switch (await SbroPermission.getGalleryAccess()) {

      case PermissionsTypes.granted:
          List<AssetPathEntity?> apel = await _getPathList();

          /// We check if the number of rows in the preload db is > 0. If so we proceed to load thoose assets. If not we load all 
          /// assets in the phone. Than we initialize the folders.
          
          bool loadedFromDb = false;
          List<AssetEntity?> quickLoadedAssets;
          List<String> invalidPath = await SavedData.instance.getInvalidPaths();

          if(await savedAssetsDb.countRows() > 0 && invalidPath.isNotEmpty) {
            quickLoadedAssets = await SbroImage.getAllAssesInDatabase(savedAssetsDb);
            print("[INFO] Loading assets from db!");
            loadedFromDb = true;
          } 
          else {
            quickLoadedAssets = await SbroImage.fetchAssets();
            print("[INFO] Loading assets from phone!");
          }

          quickLoadedAssets.shuffle();
          mainFeed.addAll(quickLoadedAssets);
          corrIndx = 0;

          _getFoldersFromGallery(apel).then( (_) {
            
            /// Notify that the folders are ready
            isFoldersReady.value = true;
            print("[INFO] Loaded all folders!");

            /// Load the rest of the feed if it was loaded from db
            if(loadedFromDb){
              List<AssetEntity?> restOfFeed = SbroImage.getValidPathAssetsList(folders, Filter.validPathsMap);
              /// Remove duplicates
              for(AssetEntity? ae in mainFeed){
                restOfFeed.remove(ae);
              }

              restOfFeed.shuffle();
              mainFeed.addAll(restOfFeed);

              print("[INFO] Updating feed from ${quickLoadedAssets.length} -> ${mainFeed.length}");
              if(loadedFromDb) setState(() {});

              /// Update the saved images for the next loading
              savedAssetsDb.removeAllRows().then( (_) => savedAssetsDb.addRandomMedias(mainFeed, Filter.savedAssets));
              
            }
          });

          setState(() {
            // The app is ready to go
            readyToGo = true;
          });
        break;

      case PermissionsTypes.permanentlyDenied: 
          // TODO: pop a warning box saying "Go to settings and give the needed..."
          print("Permission to gallery is permanentlyDenied");
        break;
          
      default:
        // TODO: maybe add a warnig banner here to
        _quickLoadImage();
    }
  }


  @override
  /// Code that will be run everytime we come back to this page.
  initState(){
    /// Make sure only runs once
    if(initializeApp){
      _quickLoadImage();
      mainFeedHash = mainFeed.hashCode;      
      initializeApp = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(readyToGo){
      return HomePage(assets: mainFeed);
    }
    else {
      return const Center(child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator()
      ));
    }
  }
}