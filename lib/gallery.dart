import 'package:flutter/material.dart';
import 'package:gallery_tok/footbar.dart';
import 'package:gallery_tok/globals.dart';
import 'package:gallery_tok/image_view.dart';
import 'package:gallery_tok/permission_box.dart';
import 'package:gallery_tok/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<AssetEntity> assets = [];
  

  bool readyToStart = false;
  Future<void>  _fetchAssets() async {
    assets = await PhotoManager.getAssetListRange(start: 0, end: 10000000);
    assets.shuffle();
    setState(() {
      readyToStart = true;
    });
  }

  AssetEntity? correntAsset;
  int corrIndx = 0;
  Future<void> deleteFile() async {
    try {
        correntAsset!.file.then(
          (file) {
            //print(file!.path.toString());
            //TODO: utilizzare un cestino in modo che l'utente possa recuperare i file eliminati per sbaglio
            file!.delete();
            assets.removeAt(corrIndx);
            setState(() {});
          }
        );
    } catch (e) {
      // Error in getting access to the file.
      print("Error while deliting file");
    }
  }

  bool askPermissionDeleting = false;
  void showPermissionBox(){
    setState(() {
      askPermissionDeleting = !askPermissionDeleting;
    });
  }

  @override
  void initState() {
    _fetchAssets();
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
        backgroundColor: primaryColor,
        body: Stack(
          children: [
            Column(
              children: [              
                SizedBox(
                  height: getHeight(context) - Footbar.fbHight,
                  child: readyToStart ? 
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (_, index) {

                        corrIndx = index;
                        correntAsset = assets[index];

                        if(assets[index].type == AssetType.video) {
                          return VideoView(video: assets[index]);
                        }
                        else { 
                          return ImageView( image: assets[index]);
                        }
                      }
                    ) 
                    :
                    const Center(child: CircularProgressIndicator())

                ),
                Footbar(deleteMedia: () => showPermissionBox()),  
              ]
            ),
            if(true) const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 10, left: 20),
                child: Text(
                  "SbroApp",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30,
                    ),
                ),
              ),
            ),

            if(askPermissionDeleting) PremissionBox(
              context: context, 
              f1: () {
                showPermissionBox();
                deleteFile();
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