import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';

class MediaDatabase {
  static Database? _database;
  String tableName = "images";

  MediaDatabase({required this.tableName});

  //Database db;
  Future<Database> get database async{
    if(_database != null) return _database!;

    _database = await _initDb(tableName);
    return _database!;

  }

  Future<Database> _initDb(String name) async{
    final dbPath = await getDatabasesPath();
    final String path = "$dbPath/$name";

    print(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';

    await db.execute('''
    CREATE TABLE $tableName ( 
      'id' $idType 
      )
    ''');
  }

  Future<int> addMedia(AssetEntity? asset) async {
    if(asset == null) return -1;

    print(asset.id);
    final Database db = await database;

    if(await existMedia(asset)){
      print("[WARN] Media already in the database. Ignoring ...");
      return -1;
    }

    final int id = await db.insert(tableName, {'id': int.parse(asset.id)});
    return id;
  }

  Future<bool> existMedia(AssetEntity? asset) async {
    if(asset == null) return false;

    final Database db = await database;

    final List<Map<String, Object?>> result = await db.query(
      tableName,
      columns: ['id'],
      where: "id = ${int.parse(asset.id)}"
    );

    int count = result.length;
    return count > 0;
  }

  Future<List<int>> readAllMediaIds() async {
    final Database db = await database;

    final List<Map<String, Object?>> result = await db.query(tableName);

    return result.map((json) => int.parse(json['id'].toString())).toList();
  }

  Future<int> removeMedia(AssetEntity? asset) async {
    if(asset == null) return -1;

    final Database db = await database;

    print("Removing Media: ${asset.title}");
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [int.parse(asset.id)],
    );
  }

  Future drop() async {
    final Database db = await database;
    db.delete(tableName);
  }

}