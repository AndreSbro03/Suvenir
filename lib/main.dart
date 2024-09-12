import 'package:flutter/material.dart';
import 'package:gallery_tok/appbar.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/footbar.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/libraries/permission.dart';
import 'package:gallery_tok/settings.dart';
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

  void _getMediaFromGallery() async {
    switch (await SbroPermission.getGalleryAccess()) {

      case PermissionsTypes.granted:
          // I need to upload all media first
          await SbroImage.fetchAssets();
          corrIndx = 0;
          print("Loaded all images");

          setState(() {
            originalAssets.addAll(assets);
            // The app is ready to go
            readyToGo = true;
          });
        break;

      case PermissionsTypes.permanentlyDenied: 
          // TODO: pop a warning box saying "Go to settings and give the needed ..."
          print("Permission to gallery is permanentlyDenied");
        break;
          
      default:
        // TODO: maybe add a warnig banner here to
        _getMediaFromGallery();
    }
  }

  _getPathList() async {
    Settings.validPathsMap = { for (var e in await PhotoManager.getAssetPathList()) e.name : true };
  }

  @override
  /// Code that will be run everytime we come back to this page.
  initState(){
    /// Make sure only runs once
    if(initializeApp){
      _getMediaFromGallery();
      _getPathList();
      initializeApp = false;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          /// Level 0: (background) 
          ///   The feed once the permission are granted and the medias are loaded.
          ///   Circular progress indicator instead.
          readyToGo ? 
            const Feed() :
            const Center(child: CircularProgressIndicator()) ,

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

        ],
      ),
    );
  }
}