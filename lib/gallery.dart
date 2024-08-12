import 'package:flutter/material.dart';
import 'package:gallery_tok/image_view.dart';
import 'package:gallery_tok/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<AssetEntity> assets = [];

  Future<void>  _fetchAssets() async {
    assets = await PhotoManager.getAssetListRange(start: 0, end: 10000000);
    assets.shuffle();
    setState(() {});
  }

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (_, index) {
          if(assets[index].type == AssetType.video) {
            return VideoView(videoFile: assets[index].file);
          }
          else { 
            return ImageView( imageFile: assets[index].file);
          }
        }
      );
  }
}