import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/db/trash_db.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/media_manager.dart';
import 'package:suvenir/libraries/permission.dart';
import 'package:suvenir/istances/saved_data.dart';

class Trash{

  static const String trashPath = "$appName.trash";

  static Future<int> moveToTrash(AssetEntity asset) async {

    if(await SbroPermission.isStoragePermissionGranted()){
      
      // String? oldPath = SbroImage.getAssetFolder(asset);
      /// Saving the absolute path beacouse if the media is in external storage we have to remember all 
      /// path not just the last folder
      String? oldPath = SbroMediaManager.getAssetFolder(asset);
      AssetEntity? out = asset;

      /// Move the asset if required
      if(await SavedData.instance.getMoveToTrashFolder()){
        print("[INFO] Trying to move the media to ${Trash.trashPath}");
        out = await SbroMediaManager.moveAsset(asset, trashPath);
        if(out == null){
          print("[ERR] Something went wrong moving asset ${asset.title}");
          return 1;
        }
      }

      /// Add the asset to the database
      /// database add {'id' = out.id, 'date' = now, 'oldPath' = oldPath}
      TrashedAsset ta = TrashedAsset(
        id: out.id, 
        date: getCorrDate(), 
        oldPath: oldPath
      );

      trashAssetsDb.addMedia(ta);
      return 0;
    }
    else{
      print("[ERR] Permission denied!");
      return 2;
    }

  }

  static void cleanTrash() async {
    /// Here we check if the trash db has some assets that need to be deleted
    List<String> needToDelete = await trashAssetsDb.getAssetsOlderThan(trashDays);
    for (String id in needToDelete) {
      if(await SbroMediaManager.deleteAssetFromId(id)){
        trashAssetsDb.removeMedia(id);
      }
    }
  }

 static Future<void> restoreAssetFromTrash(String id) async {
    if(id.isEmpty) {
      print("[WARN] Id is null, ignoring!");
      return;
    }

    AssetEntity? ae = await AssetEntity.fromId(id); 

    if(ae == null) {
      print("[ERR] Error loading asset!");
      return;
    }

    String oldPath = await trashAssetsDb.getAssetOldPath(id);
    print("[INFO] Restoring Asset in $oldPath");

    /// TODO: be sure that the way you save the path is coerent
    /// If the path is changed we restore the image
    if(oldPath != SbroMediaManager.getAssetFolder(ae)) {
      if(await SbroMediaManager.moveAsset(ae, oldPath) != null) trashAssetsDb.removeMedia(id);
    }
  }

}