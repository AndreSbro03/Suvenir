import 'package:sqflite/sqflite.dart';

abstract class AssetsDb {
  Database? _database;
  final String tableName;

  AssetsDb({required this.tableName});

  Future<Database> get database async{
    if(_database != null) return _database!;

    _database = await initDb(tableName);
    return _database!;

  }

  Future<Database> initDb(String name);

  Future<bool> existMedia(String id) async {
    if(id.isEmpty) return false;
    final Database db = await database;

    final List<Map<String, Object?>> result = await db.query(
      tableName,
      columns: ['id'],
      where: "id = $id"
    );

    int count = result.length;
    return count > 0;
  }

  Future<List<String>> readAllMediaIds() async {
    final Database db = await database;

    final List<Map<String, Object?>> result = await db.query(tableName);

    return result.map((json) => json['id'].toString()).toList();
  }

  Future<int> removeMedia(String id) async {

    final Database db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future drop() async {
    final Database db = await database;
    db.delete(tableName);
  }

}