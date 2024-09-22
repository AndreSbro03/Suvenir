import 'dart:io';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/db/likedDb.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/permission.dart';
import 'package:gallery_tok/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

class SbroImage{


  static const String trashPath = "$appName.trash/";

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

  static void moveToTrash(AssetEntity asset) async {

    if(await SbroPermission.isStoragePermissionGranted()){

      String? oldPath = await getAssetAbsolutePath(asset);
      
      /// Move the asset
      AssetEntity? out = await moveAsset(asset, trashPath);
      if(out == null){
        print("[ERR] Something went wrong moving asset ${asset.title}");
        return;
      }

      /// Add the asset to the database
      /// database add {'id' = out.id, 'date' = now, 'oldPath' = oldPath}

    }

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

  static Future<void> shareAsset(AssetEntity? asset) async {
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
    //print(path);

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
      //print(folderName);
      //print(Settings.validPathsMap[folderName]);
      if(!(Settings.validPathsMap[folderName] ?? true)){
        assets.removeAt(i);
        modified = true;
      }
      else i++;
    }
    if(modified) Feed.realoadFeed.value = true;
  }

  static Future<List<AssetEntity?>> getAllAssesInDatabase(LikedDatabase db) async {
    List<int> mediaIds = await db.readAllMediaIds();
    List<AssetEntity?> out = [];
    for (int id in mediaIds) {
      out.add(await AssetEntity.fromId(id.toString()));
    }
    return out;
  }

  static Future<AssetEntity?> moveAsset(AssetEntity? asset, String newPath) async {

    if(asset == null) {
      print("[WARN] The file passed was null, ignoring!");
      return null;
    }

    File? fl = await asset.file;
    
    if(fl == null) {
      print("[WARN] The file passed was null, ignoring!");
      return null;
    }

    AssetEntity? out;
    /// Move the Media to a specific folder in the memory
    switch (asset.type) {
 
      case AssetType.image:
        out = await PhotoManager.editor.saveImageWithPath(
          await getAssetAbsolutePath(asset), 
          title: asset.title!,
          relativePath: newPath
        );
        break;

      case AssetType.video:
        out = await PhotoManager.editor.saveVideo(
          await asset.file.then((file) => file!), 
          title: asset.title!,
          relativePath: newPath
        );
        break;

      case AssetType.audio:
      case AssetType.other:
        print("[WAR] This file type is not supported yet!");
        break;
    }
    

    return out;

    /*
    Move to app folder (Photo manager can't see them after)
    final newDir = await getDirectory(newPath);

    try {
      await fl.rename(newDir);
    }
    on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final File newFile = await fl.copy("$newDir/${asset.title}");
      await fl.delete();
    }
    */
  }

  static Future<String> getDirectory(String dirName) async {
    String appDir = await getExternalStorageDirectory().then( (dir) => dir!.path);

    if(await Directory("$appDir/$dirName").exists()){
      print("[INFO] Directory $appDir/$dirName already exists!");
      return "$appDir/$dirName";
    }

    // TODO: the following wont work on IOS
    String newDir = await Directory("$appDir/$dirName").create(recursive: true).then( (dir) => dir.path);
    print("[INFO] Directory: $newDir");
    return newDir;
  }


}
