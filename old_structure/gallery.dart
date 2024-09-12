import 'package:flutter/material.dart';
import 'package:gallery_tok/account.dart';
import 'package:gallery_tok/home_page/appbar.dart';
import 'package:gallery_tok/home_page/feed.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/media_manager/image.dart';
import 'package:gallery_tok/home_page/permission_box.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {

  late List<AssetPathEntity> paths = [];
  List<bool> isPathValid = [];

  bool readyToStart = false;
  bool askPermissionDeleting = false;
  bool pauseVideo = false;

  void showPermissionBox(){
    setState(() {
      askPermissionDeleting = !askPermissionDeleting;
    });
  }

  void applySettings(){
    setState(() {
      readyToStart = false;
    });
    _getMedia();
  }

  void _getPaths() async{
    // Get all the paths on the users phone
    paths.addAll(await PhotoManager.getAssetPathList());
    isPathValid = List<bool>.generate(paths.length, (i) => true);
    _getMedia();
  }

  void _getMedia() async {
    assets = [];
    await SbroImage.fetchAssets(Wrapper(assets), paths, isPathValid);
    print("Loaded all photos!");
    setState(() {
       readyToStart = true;
       if(assets.isNotEmpty) corrIndx = 0;
    });
  }

  @override
  void initState() {
    SbroDatabase.instance.getAllMedia().then(
      (list) => likedIds.addAll(list)
    );
    _getPaths();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      /// If user longPress on screen we don't wont to show usless stuff
      onLongPressStart: (_) => setState(() {
        immersive = false;
      }),
      onLongPressEnd: (_) => setState(() {
        immersive = true;
      }),

      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Feed(
              readyToStart: readyToStart, 
              pauseVideo: Wrapper(pauseVideo),
              showPermissionBox: showPermissionBox, 
              gotoAccount: () {
                setState(() {
                 pauseVideo = true;
                });                               
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Account())
                );
              },                          
            ),
        
            /// Title and Settings Icon
            SbroAppBar(
              paths: paths, 
              isPathValid: Wrapper(isPathValid), 
              applySettings: applySettings,                              
            ),
        
            if(askPermissionDeleting) PremissionBox(
              context: context, 
              f1: () {
                showPermissionBox();
                SbroImage.deleteFile(Wrapper(assets), corrIndx!);
                setState(() {});
              }, 
              f2: (){
                showPermissionBox();
              })
          ]
        ),
      ),
    );
  }
}