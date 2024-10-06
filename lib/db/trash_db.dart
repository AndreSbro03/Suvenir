import 'package:gallery_tok/db/assets_db.dart';
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

  Future<String> getAssetDeletionTime(String id) async {
    if(id.isEmpty) return '';
    return await _getTrashedAssetField(id, TrashedAssetFields.date);   
  }

  Future<String> getAssetOldPath(String id) async {
    if(id.isEmpty) return '';
    return await _getTrashedAssetField(id, TrashedAssetFields.oldPath);   
  }

}