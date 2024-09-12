import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/settings.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

class SbroImage {

  static const int scrollDurationMilliseconds = 500;
 
  static Future<void> fetchAssets() async {
    assetsCount =  await PhotoManager.getAssetCount();
    assets.addAll(await PhotoManager.getAssetListRange(start: 0, end: assetsCount!));
    assets.shuffle();
  }

  static String getAssetPath(AssetEntity? asset) {
    if(asset != null){
      return "${asset.relativePath!}/${asset.title!}";
    }
    return "";
  }

  static void moveToTrash() {

    assets[corrIndx!] = null;
    feedController.nextPage(duration: const Duration(milliseconds: scrollDurationMilliseconds), curve: Curves.easeInOut);

    // TODO
  }

  static Future<void> deleteAsset(AssetEntity? asset) async {

    if(corrIndx == null || asset == null) {
      print("Trying to delete un unavailable asset!");
      return;
    }

    try {
        asset.file.then(
          (file) {
            if(file == null) return;
            file.delete();         
          }
        );
    } catch (e) {
      // Error in getting access to the file.
      print("Error while deliting file");
    }
  }

  static Future<void> shareMedia(AssetEntity? asset) async {
    if(asset == null) {
      print("Trying to share an unavailable asset!");
      return;
    }

    String corrPath = getAssetPath(asset);
    //print(corrPath);
    final result = await Share.shareXFiles([XFile(corrPath)]);
                      
    if(result.status == ShareResultStatus.success) print("File condiviso con successo");
    else print("Qualcosa è andato storto nella condivisione del file");
  }

  static String getAssetFolder(AssetEntity? asset){

    if(asset == null) {
      print("Trying to get the folder of an unavailable asset!");
      return "";
    }
    return asset.relativePath!.split('/').last;
  }

  /// Guarantee that the next @numNextUpdate medias are all valid medias
  static void updateAssets(index, numNextUpdate) {
    for(int i = index + 1; i < assets.length && i < (index + numNextUpdate);) {
      String name = SbroImage.getAssetFolder(assets[i]);
      if(!(Settings.validPathsMap[name] ?? true)){
        assets.removeAt(i);
      }
      else i++;
    }
  }
}
