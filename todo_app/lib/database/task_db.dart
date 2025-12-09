import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDB {
  static final TaskDB instance = TaskDB._init();
  static Database? _database;

  TaskDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT,
        description TEXT,
        priority TEXT
      )
    ''');
  }
}
