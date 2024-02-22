import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/Model/note.dart';

class DBHelper {
  static Database? _database;
  static const int _version = 1;
  static const String _tableName = 'notes';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Note>> find({String? query}) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        _tableName,
        where: 'title LIKE ?',
        whereArgs: ['%$query%'],
      );
    } else {
      maps = await db.query(_tableName);
    }
    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  Future<List<Note>> queryToday() async {
    Database db = await instance.database;
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [today],
    );
    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  Future<List<Note>> queryUpcoming() async {
    Database db = await instance.database;
    final tomorrow =
        DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 1)));
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'date >= ?',
      whereArgs: [tomorrow],
    );
    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, title TEXT, description TEXT, date TEXT, endTime TEXT)",
        );
      },
    );
  }

  Future<int> insert(Note note) async {
    Database db = await instance.database;
    return await db.insert(_tableName, note.toJson());
  }

  Future<List<Note>> query() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
