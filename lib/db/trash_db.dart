import 'package:gallery_tok/db/assets_db.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:sqflite/sqflite.dart';

class TrashedAsset {
  final String id;
  final String date;
  final String oldPath;

  TrashedAsset({required this.id, required this.date, required this.oldPath});

  static TrashedAsset fromJson(Map<String, Object?> json) => TrashedAsset(
      id: json[TrashedAssetFields.id] as String,
      date: json[TrashedAssetFields.date] as String,
      oldPath: json[TrashedAssetFields.oldPath] as String,
  );


  Map<String, Object?> toJson() => {
        TrashedAssetFields.id: id,
        TrashedAssetFields.date: date,
        TrashedAssetFields.oldPath: oldPath,
      };

}

class TrashedAssetFields {
  static final List<String> values = [
    /// Add all fields
    id, date, oldPath
  ];

  static const String id = 'id';
  static const String date = 'image';
  static const String oldPath = 'name';
}

class TrashDatabase extends AssetsDb{
  TrashDatabase({required super.tableName});

  @override
  Future<Database> initDb(String name) async{
    final dbPath = await getDatabasesPath();
    final String path = "$dbPath/$name";

    print("[INFO] Trash db path: $path");

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $tableName ( 
      '${TrashedAssetFields.id}' $idType,
      '${TrashedAssetFields.date}' $textType,
      '${TrashedAssetFields.oldPath}' $textType
      )
    ''');
  }

  Future<int> addMedia(TrashedAsset? trashedAsset) async {
    if(trashedAsset == null) return -1;

    final Database db = await database;

    if(await existMedia(trashedAsset.id)){
      print("[WARN] Media already in the database. Ignoring ...");
      return -1;
    }

    final int id = await db.insert(tableName, trashedAsset.toJson());
    return id;
  }

  Future<String> _getTrashedAssetField(String id, String assetField) async {

    final Database db = await database;

    final List<Map<String, Object?>> result = await db.query(
      tableName,
      columns: [(assetField)],
      where: "${TrashedAssetFields.id} = $id"
    );

    String out = result.first[assetField].toString();

    return out;

  }

  Future<List<Map<String, Object?>>> _getAllTrashedAssetFields(String assetField) async {

    final Database db = await database;

    return await db.query(
      tableName,
      columns: [TrashedAssetFields.id, assetField],
    );

  }


  Future<String> getAssetDeletionTime(String id) async {
    if(id.isEmpty) return '';
    return await _getTrashedAssetField(id, TrashedAssetFields.date);   
  }

  Future<String> getAssetOldPath(String id) async {
    if(id.isEmpty) return '';
    return await _getTrashedAssetField(id, TrashedAssetFields.oldPath);   
  }

  /// Return a combination (id, date)
  Future<List<Map<String, Object?>>> getAssetsTrashedDate() {
    return _getAllTrashedAssetFields(TrashedAssetFields.date);
  }

  Future<List<String>> getAssetsOlderThan(int days) async {

    /// get all assets in trash (id, date)
    List<Map<String, Object?>> assetsData = await getAssetsTrashedDate();
    
    List<String> out = [];
    String today = getCorrDate();
    /// if date is passed by more than @param days days than we add the id to the list
    for (Map<String, Object?> x in assetsData) {
      String date = x[TrashedAssetFields.date].toString();
      if(dateDistance(today, date) >= days){
        String id = x[TrashedAssetFields.id].toString();
        print(id);
        out.add(id);
      }
    }

    return out;
  }

}