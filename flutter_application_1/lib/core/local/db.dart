import 'package:flutter_application_1/models/driver.user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database? _database;
  static const String dbName = 'driver_users.db';
  static const String tableName = 'driver_users';

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null, initialize it
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // Get the directory path for Android or iOS to store the database.
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, dbName);

    // Open the database. Can also add an onCreate callback.
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create the table
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            username TEXT,
            password TEXT,
            image TEXT
          )
        ''');
      },
    );
  }

  // Insert or update a DriverUser in the local database
  Future<void> insertOrUpdateDriverUser(DriverUser user) async {
    final Database db = await database;
    await db.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a DriverUser from the local database using userId
  Future<DriverUser?> getDriverUser(String userId) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return DriverUser.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<DriverUser>> getAllDriverUsers() async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (index) {
      return DriverUser.fromMap(maps[index]);
    });
  }

  // Delete a DriverUser from the local database using userId
  Future<void> deleteDriverUser(String userId) async {
    final Database db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
