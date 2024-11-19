import 'dart:math';

import 'package:suvenir/db/assets_db.dart';
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

    final Database db = await database;

    if(await existMedia(asset.id)){
      print("[WARN] Media already in the database. Ignoring ...");
      return -1;
    }

    final int id = await db.insert(tableName, {'id': int.parse(asset.id)});
    return id;
  }

  /// Add all passed assets, ignoring erros for sigle ones.
  void addMedias(List<AssetEntity?> assets, [int? N]) async {
    int count = N??assets.length;
    for (int i = 0; i < count; i++) {
      addMedia(assets[i]);
    }
  } 

  void addRandomMedias(List<AssetEntity?> assets, int N ){
    int end = min(assets.length, N);
    List<AssetEntity?> add = [];
    add.addAll(assets);
    add.shuffle();
    addMedias(add, end);
  }

}