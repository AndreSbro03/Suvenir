import 'package:flutter/material.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/libraries/db.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/settings.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

class SbroImage{

  static const int scrollDurationMilliseconds = 500;
 
  static Future<void> fetchAssets() async {
    int assetsCount =  await PhotoManager.getAssetCount();
    assets.addAll(await PhotoManager.getAssetListRange(start: 0, end: assetsCount));
    assets.shuffle();
  }

  static Future<String> getAssetAbsolutePath(AssetEntity? asset) async{
    if(asset != null){
      // return "${asset.relativePath!}/${asset.title!}";
      return asset.file.then((file) => file!.path);
    }
    return "";
  }

  static String getAssetRelativePath(AssetEntity? asset) {
    if(asset != null){
      if(asset.relativePath!.endsWith('/')){
        return "${asset.relativePath!}${asset.title!}";
      }
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

    String corrPath = await getAssetAbsolutePath(asset);
    print(corrPath);
    final result = await Share.shareXFiles([XFile(corrPath)]);
                      
    if(result.status == ShareResultStatus.success) print("File condiviso con successo");
    else print("Qualcosa è andato storto nella condivisione del file");
  }

  static String getAssetFolder(AssetEntity? asset){

    if(asset == null) {
      print("Trying to get the folder of an unavailable asset!");
      return "";
    }
    /// if the path is "Store/0/User/Picture/image.png" we take only "Picture"
    List<String> path = getAssetRelativePath(asset).split('/');
    print(path);
    /// Removed the name of the file
    path.removeLast();
    /// Returned the last folder
    return path.last;
  }

  /// Guarantee that the next @numNextUpdate medias are all valid medias
  static void updateAssets(index, numNextUpdate) {
    bool modified = false;
    for(int i = index + 1; i < assets.length && i < (index + numNextUpdate);) {
      String folderName = SbroImage.getAssetFolder(assets[i]);
      print(folderName);
      print(Settings.validPathsMap[folderName]);
      if(!(Settings.validPathsMap[folderName] ?? true)){
        assets.removeAt(i);
        modified = true;
      }
      else i++;
    }
    if(modified) Feed.realoadFeed.value = true;
  }

  static Future<List<AssetEntity?>> getAllAssesInDatabase(MediaDatabase db) async {
    List<int> mediaIds = await db.readAllMediaIds();
    List<AssetEntity?> out = [];
    for (int id in mediaIds) {
      out.add(await AssetEntity.fromId(id.toString()));
    }
    return out;
  }
}
