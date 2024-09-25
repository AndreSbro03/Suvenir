import 'package:gallery_tok/db/assets_db.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';

class LikeDatabase extends AssetsDb{
  LikeDatabase({required super.tableName});
  
  @override
  Future<Database> initDb(String name) async{
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

    if(await existMedia(int.parse(asset.id))){
      print("[WARN] Media already in the database. Ignoring ...");
      return -1;
    }

    final int id = await db.insert(tableName, {'id': int.parse(asset.id)});
    return id;
  }

}