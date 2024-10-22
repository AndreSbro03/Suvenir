import 'package:flutter/material.dart';
import 'package:suvenir/homepage.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/image.dart';
import 'package:suvenir/libraries/permission.dart';
import 'package:suvenir/settings.dart';
import 'package:photo_manager/photo_manager.dart';


/// Here we setup the application and require the gallery permission.
/// Once the user has provide that we start the feed. 
void main() {
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
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


  /// If there are two folders one in the phone and one in a external disk with the same name the function PhotoManager.getAssetPathList() 
  /// will take only the id of one of the two.
  /// ```dart
  ///     1 - Search all folders in the phone.
  ///     2 - Remove the trashPath from the list.
  ///     3 - Create the validity map and set all values true.
  ///     4 - Return the List<AssetPathEntity?> founded.
  /// ```
  Future<List<AssetPathEntity?>> _getPathList() async {

    /// hasAll : false make sure to remove the "Recent" folder that contains copy of other assets present in other folders
    List<AssetPathEntity> apel = await PhotoManager.getAssetPathList(hasAll: false);
      
    Settings.validPathsMap = { for (var e in apel) e.name : true };
    Settings.validPathsMap.remove(SbroImage.trashPath);

    /// print("[INFO] Getting paths: ${Settings.validPathsMap.toString()}");

    return apel;
  }

  void _getMediaFromGallery() async {
    switch (await SbroPermission.getGalleryAccess()) {

      case PermissionsTypes.granted:
          List<AssetPathEntity?> apel = await _getPathList();

          // I need to upload all media first
          folders = await SbroImage.fetchAssetsByFolders(apel);
          originalAssets = SbroImage.getValidPathAssetsList(folders, Settings.validPathsMap);
          //SbroImage.fetchAssets();
          originalAssets.shuffle();
          corrIndx = 0;
          print("[INFO] Loaded all images!");

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
        _getMediaFromGallery();
    }
  }

  void _cleanTrash() async {
     /// Here we check if the trash db has some assets that need to be deleted
      List<String> needToDelete = await trashAssetsDb.getAssetsOlderThan(trashDays);
      for (String id in needToDelete) {
        SbroImage.deleteAssetFromId(id);
        trashAssetsDb.removeMedia(id);
      }
  }

  @override
  /// Code that will be run everytime we come back to this page.
  initState(){
    /// Make sure only runs once
    if(initializeApp){
      _getMediaFromGallery();
      _cleanTrash();
      mainFeedHash = mainFeed.hashCode;      
      initializeApp = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(readyToGo){
      mainFeed.addAll(originalAssets);
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