import 'package:gallery_tok/globals.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class SbroImage {

  /// @brief Get the media from user phone @param paths exept the one that are false in @param is PathValid 
  static Future<void> fetchAssets( Wrapper<List<AssetEntity>> assets, List<AssetPathEntity> paths, List<bool> isPathValid) async {
    
    List<Future?> out = [];
    
    // If the path is in the black list we don't add the photos to the feed.
    for(int i = 0; i < paths.length; ++i){
      /// If the path contains the indicates paths if we want them we add them, else we skip them. We get all the path in 
      /// parallel then we save the last one output
      if(isPathValid[i]){
        out.add(paths[i].getAssetListRange(start: 0, end: 10000000).then(
          (list) => assets.value.addAll(list)));
      }
    }
    
    /// Here we wait that all the path are loaded.
    for(int i = 0; i < out.length; ++i){
      await out[i];
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

class SbroDatabase extends SbroImage {
 
  static const String name = "liked"; 
  static final SbroDatabase instance = SbroDatabase._init();
  static Database? _database;

  SbroDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('$name.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final String dbPath = await getDatabasesPath();
    final String path = "$dbPath/$filePath";
    print(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    //const dateType = 'DATETIME';

    await db.execute('''
      CREATE TABLE $name ( 
        id $idType
        )
      ''');
  }

  Future<void> addMedia(int id, DateTime date) async {
    final db = await instance.database;
    await db.insert(name, {'id': id});
  }

  Future<String> getMedia(int id) async {
    final db = await instance.database;

    final List<Map<String, Object?>> maps = await db.query(
      name,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first['id'].toString();
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<String>> getAllMedia() async {
    final db = await instance.database;
    List<String> out = [];

    final List<Map<String, Object?>> result = await db.query(name);

    result.forEach((map) => out.add(map['id'].toString()));

    return out;
  }

  /*
  Future<int> updatePlayer(Player player) async {
    final db = await instance.database;

    return db.update(
      tablePlayers,
      player.toJson(),
      where: '${PlayerFields.id} = ?',
      whereArgs: [player.id],
    );
  }
  */

  Future<int> removeMedia(int id) async {
    final db = await instance.database;

    return await db.delete(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future drop() async {
    final db = await instance.database;

    db.delete(name);
  }

}