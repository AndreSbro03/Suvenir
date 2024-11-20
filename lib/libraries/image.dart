import 'dart:collection';
import 'dart:io';
import 'package:suvenir/db/assets_db.dart';
import 'package:suvenir/db/trash_db.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/permission.dart';
import 'package:suvenir/libraries/saved_data.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mutex/mutex.dart';

class SbroImage{

  static const int dimFolderPartition = 512;

  static Future<List<AssetEntity>> fetchAssets() async {
    int assetsCount =  await PhotoManager.getAssetCount();
    return PhotoManager.getAssetListRange(start: 0, end: assetsCount);
  }

  static Future<Map<String, List<AssetEntity?>>> fetchAssetsByFolders(List<AssetPathEntity?> paths) async {

    Map<String, List<AssetEntity?>> out = HashMap();

    /// List of tasks to read each folder in parallel
    List<Future<void>> tasks = [];
    
    for (AssetPathEntity? path in paths) {
      
      if(path == null) continue;

      /// Add the task
      tasks.add(
        // ignore: void_checks
        path.assetCountAsync.then((assetCount) {

            // Suddividi gli asset in partizioni
            List<Future<void>> subTasks = [];
            
            print('[INFO] Nome cartella: ${path.name}, ID cartella: ${path.id}, Count: $assetCount');

            for (int page = 0; page * dimFolderPartition < assetCount; page++) {

              // Aggiungi ogni partizione a subTasks
              subTasks.add(
                path.getAssetListPaged(page: page, size: dimFolderPartition).then((ael) {

                  /// If two folders have the same name we want to concat the ael
                  out.putIfAbsent(path.name, () => []).addAll(ael);
       
                  print("[INFO] Loaded ${path.name} parition $page: ${ael.length} assets");
                }),
              );
            }

          // Attendi tutti i sottotask di getAssetListRange() per la cartella corrente
          return Future.wait(subTasks);
        }),
      );

    }

    /// Wait all tasks
    await Future.wait(tasks);

    return out;
  }

  static List<AssetEntity?> getValidPathAssetsList(Map<String, List<AssetEntity?>> folders, Map<String, bool> validMap) {

    List<AssetEntity?> out = [];

    for (String folderName in folders.keys) {      
      /// Filter the trashPath since is not in validMap 
      /// print("[INFO] Folder name: $folderName");
      if(validMap.containsKey(folderName) && validMap[folderName]!){
        /// print("[INFO] Total assets: ${folders[folderName]!.length}");
        out.addAll(folders[folderName]!);
      }
    }
    return out;
  }

  static Future<String> getAssetAbsolutePath(AssetEntity? asset) async{
    if(asset != null){
      // return "${asset.relativePath!}/${asset.title!}";
      return asset.file.then((file) => file!.path);
    }
    return "";
  }

  static Future<String> getAssetAbsolutePathFolder(AssetEntity? asset) async{
    String abPath = await getAssetAbsolutePath(asset);
    if(abPath == "") return "";
    List abPathList = abPath.split('/');
    abPathList.removeLast();  
    abPath = abPathList.join('/');
    print("[INFO] Absolute path folder: $abPath");
    return abPath;  
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

  
  /// Delete the asset from the phone and add increment the cleared_space by the dimension of the asset
  static Future<bool> deleteAsset(AssetEntity? asset) async {

    if(asset == null) {
      print("Trying to delete un unavailable asset!");
      return false;
    }

    try{
      if(await SbroPermission.isStoragePermissionGranted()){
        asset.file.then(
          (file) async {
            if(file == null) return false;
            
            SavedData.instance.addSavedSpace(await file.length());

            file.delete();
            return true;         
          }
        );
      } else{
        throw Exception('Permission not granted!');
      }
    } catch (e) {
      // Error in getting access to the file.
      print("[ERR] Error while deliting file: $e");
    }
    return false;
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
      print("[WARN] Trying to get the folder of an unavailable asset!");
      return "";
    }
    /// if the path is "Store/0/User/Picture(/)" we take only "Picture"
    String? path = asset.relativePath;
    if(path == null){
      print("[ERR] Something went wrong getting relative path!");
      return "";
    }

    List<String> folders = path.split('/');

    /// Sometimes path ends with / so we have to remove the last empty element
    if(folders.last == '') folders.removeLast();
    
    /// Returned the last folder
    return folders.last;
  }


  /// Guarantee that the next @numNextUpdate medias are all valid medias
  static Future<void> updateAssets(List<AssetEntity?> assets , int index, int numNextUpdate) async {
    for(int i = index; i < assets.length && i < (index + numNextUpdate);) {
      ///String folderName = getAssetFolder(assets[i]);
      //print(folderName);
      //print(Settings.validPathsMap[folderName]);

      /// If the assets is null or the assets has been deleted or moved we remove it
      if(assets[i] == null || !(await assets[i]!.exists)){
        //print("[INFO] Removed null!");
        assets.removeAt(i);
      }
      /// If the assets is in the trash we remove it
      else if (await trashAssetsDb.existMedia(assets[i]!.id)){
        assets.removeAt(i);
      }
      /// If the path is the trashed one we remove the asset
      // else if(folderName == Trash.trashPath){
      //   //print("[INFO] Removed invalid!");
      //   assets.removeAt(i);
      // }   
      else i++;
    }
  }

  /// Return all the assetsEntity in the trash and map them with the number of days until they are going to be
  /// removed
  static Future<List<Map<AssetEntity?, int>>> getAssetsTrashedDate() async {

    List<Map<String, Object?>> dbData = await trashAssetsDb.getAssetsTrashedDate();
    List<Map<AssetEntity?, int>> out = [];

    List<Future<void>> tasks = [];
    Mutex m = Mutex();
    
    for (Map<String, Object?> map in dbData) {
      String id = map[TrashedAssetFields.id].toString();
      tasks.add( AssetEntity.fromId(id).then(
        (ae) async {
          // If ae is null we remove that from the database
          if(ae == null) {
            await m.protect( () async {
              trashAssetsDb.removeMedia(id);
            });
          }
          else{
            String d = map[TrashedAssetFields.date].toString();
            int dateUntilRemove = trashDays - dateDistance(getCorrDate(), d);
             await m.protect( () async {
              out.add({ae : dateUntilRemove});
            });
          }
        }
      ));
    }

    await Future.wait(tasks);
    
    return out;
  }

  static Future<List<AssetEntity?>> getAllAssesInDatabase(AssetsDb db) async {
    List<String> mediaIds = await db.readAllMediaIds();
    List<AssetEntity?> out = [];
    for (String id in mediaIds) {
      AssetEntity? ae = await AssetEntity.fromId(id);
      
      // If ae is null we remove that from the database
      if(ae == null){
        db.removeMedia(id);
      }
      else{
        out.add(ae);
      }
    }
    return out;
  }

  static Future<bool> deleteAssetFromId(String id) async {
    return SbroImage.deleteAsset(await AssetEntity.fromId(id));
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
        print("[INFO] Getting path: ${fl.path} -> $newPath");
        out = await PhotoManager.editor.saveImageWithPath(
          fl.path,
          title: asset.title ?? "image",
          relativePath: newPath
        );
        break;

      case AssetType.video:
        out = await PhotoManager.editor.saveVideo(
          fl, 
          title: asset.title ?? "video",
          relativePath: newPath
        );
        break;

      case AssetType.audio:
      case AssetType.other:
        print("[WAR] This file type is not supported yet!");
        break;
    }

    if(out != null) {
      fl.delete();
    }
    
    return out;

  }

}
