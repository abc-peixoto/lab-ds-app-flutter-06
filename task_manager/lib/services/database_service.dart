import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER NOT NULL,
        priority TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        dueDate TEXT,
        categoryId TEXT,
        photoPath TEXT,
        completedAt TEXT,
        completedBy TEXT,
        latitude REAL,
        longitude REAL,
        locationName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN dueDate TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tasks ADD COLUMN categoryId TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE tasks ADD COLUMN photoPath TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN completedAt TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN completedBy TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE tasks ADD COLUMN longitude REAL');
      await db.execute('ALTER TABLE tasks ADD COLUMN locationName TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE tasks ADD COLUMN updatedAt TEXT NOT NULL DEFAULT \'\'');
      await db.execute('ALTER TABLE tasks ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0');
      await db.execute('''
        CREATE TABLE sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId TEXT NOT NULL,
          operation TEXT NOT NULL, 
          payload TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
    }
    print('✅ Banco migrado de v$oldVersion para v$newVersion');
  }

  Future<void> addToSyncQueue(String taskId, String operation, {Map<String, dynamic>? payload}) async {
    final db = await database;
    await db.insert('sync_queue', {
      'taskId': taskId,
      'operation': operation,
      'payload': payload != null ? jsonEncode(payload) : null,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'createdAt ASC');
  }

  Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }


  Future<Task> create(Task task) async {
    final db = await database;
    final taskToInsert = task.copyWith(isSynced: false, updatedAt: DateTime.now());
    await db.insert('tasks', taskToInsert.toMap());
    await addToSyncQueue(task.id, 'CREATE', payload: taskToInsert.toMap());
    return taskToInsert;
  }

  Future<Task?> read(String id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> readAll({bool orderByDueDate = false}) async {
    final db = await database;
    final orderBy = orderByDueDate 
        ? 'CASE WHEN dueDate IS NULL THEN 1 ELSE 0 END, dueDate ASC, createdAt DESC'
        : 'createdAt DESC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> update(Task task) async {
    final db = await database;
    final taskToUpdate = task.copyWith(isSynced: false, updatedAt: DateTime.now());
    final result = await db.update(
      'tasks',
      taskToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await addToSyncQueue(task.id, 'UPDATE', payload: taskToUpdate.toMap());
    return result;
  }

  Future<int> delete(String id) async {
    final db = await database;
    final result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    await addToSyncQueue(id, 'DELETE');
    return result;
  }

  Future<List<Task>> getTasksNearLocation({
    required double latitude,
    required double longitude,
    double radiusInMeters = 1000,
  }) async {
    final allTasks = await readAll();

    return allTasks.where((task) {
      if (!task.hasLocation) return false;

      final latDiff = (task.latitude! - latitude).abs();
      final lonDiff = (task.longitude! - longitude).abs();
      final distance = ((latDiff * 111000) + (lonDiff * 111000)) / 2;

      return distance <= radiusInMeters;
    }).toList();
  }
}