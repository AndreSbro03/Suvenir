import 'package:gallery_tok/globals.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

class SbroImage {

  /// @brief Get the media from user phone exept (@param black == true) or only (@param black == false) the one contained in 
  /// @param blackWhitePaths 
  static Future<void> fetchAssets( Wrapper<List<AssetEntity>> assets, List<AssetPathEntity> paths, List<bool> isPathValid) async {
    
    // If the path is in the black list we don't add the photos to the feed.
    for(int i = 0; i < paths.length; i++){
      /// If the path contains the indicates paths if we want them (they are white) we add them, else we skip them
      /// ----------------------
      /// | cont | black | out |   --> XOR
      /// ----------------------
      ///   0 - 0 - 0
      ///   0 - 1 - 1
      ///   1 - 0 - 1
      ///   1 - 1 - 0
      if(isPathValid[i]){
        List<AssetEntity> pathAssets = await paths[i].getAssetListRange(start: 0, end: 10000000);
        assets.value.addAll(pathAssets);
      }
    }

    assets.value.shuffle();
  }

  static String getAssetPath(AssetEntity? asset) {
    if(asset != null){
      return "${asset.relativePath!}/${asset.title!}";
    }
    return "";
  }


  static Future<void> deleteFile(Wrapper<List<AssetEntity>> assets, int idx) async {
    try {
        assets.value[idx].file.then(
          (file) {
            //TODO: utilizzare un cestino in modo che l'utente possa recuperare i file eliminati per sbaglio
            file!.delete();
            assets.value.removeAt(idx);
          }
        );
    } catch (e) {
      // Error in getting access to the file.
      print("Error while deliting file");
    }
  }

  static Future<void> shareMedia(AssetEntity asset) async {
    String corrPath = getAssetPath(asset);
    //print(corrPath);
    final result = await Share.shareXFiles([XFile(corrPath)]);
                      
    if(result.status == ShareResultStatus.success) print("File condiviso con successo");
    else print("Qualcosa è andato storto nella condivisione del file");
  }


}