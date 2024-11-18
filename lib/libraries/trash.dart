import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/db/trash_db.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/image.dart';
import 'package:suvenir/libraries/permission.dart';

class Trash{

  static const String trashPath = "$appName.trash";

  static void moveToTrash(AssetEntity asset) async {

    if(await SbroPermission.isStoragePermissionGranted()){

      String? oldPath = SbroImage.getAssetFolder(asset);

      /// Move the asset
      AssetEntity? out = await SbroImage.moveAsset(asset, trashPath);
      if(out == null){
        print("[ERR] Something went wrong moving asset ${asset.title}");
        return;
      }

      /// Add the asset to the database
      /// database add {'id' = out.id, 'date' = now, 'oldPath' = oldPath}
      TrashedAsset ta = TrashedAsset(
        id: out.id, 
        date: getCorrDate(), 
        oldPath: oldPath
      );

      trashAssetsDb.addMedia(ta);

    }
  }

  static void cleanTrash() async {
    /// Here we check if the trash db has some assets that need to be deleted
    List<String> needToDelete = await trashAssetsDb.getAssetsOlderThan(trashDays);
    for (String id in needToDelete) {
      SbroImage.deleteAssetFromId(id);
      trashAssetsDb.removeMedia(id);
    }
  }

 static Future<AssetEntity?> restoreAssetFromTrash(String id) async {
    if(id.isEmpty) {
      print("[WARN] Id is null, ignoring!");
      return null;
    }

    AssetEntity? ae = await AssetEntity.fromId(id); 

    if(ae == null) {
      print("[ERR] Error loading asset!");
      return null;
    }

    String oldPath = await trashAssetsDb.getAssetOldPath(id);
    trashAssetsDb.removeMedia(id);
    print("[INFO] Restoring Asset in $oldPath");
    return SbroImage.moveAsset(ae, oldPath);  
  }

}