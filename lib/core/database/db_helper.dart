import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/user_model.dart';
import '../../data/models/book_model.dart';
import '../../data/models/rating_model.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shahid_library.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // جدول کاربران
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        national_code TEXT UNIQUE NOT NULL,
        avatar_seed TEXT,
        avatar_style TEXT,
        bio TEXT,
        theme_preference TEXT
      )
    ''');

    // جدول کتاب‌ها
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        description TEXT,
        cover_url TEXT,
        file_url TEXT,
        file_path TEXT,
        type TEXT NOT NULL,
        category TEXT,
        rating REAL DEFAULT 0,
        rating_count INTEGER DEFAULT 0,
        is_downloaded INTEGER DEFAULT 0,
        downloaded_at TEXT
      )
    ''');

    // جدول امتیازات
    await db.execute('''
      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // جدول همگام‌سازی (برای آفلاین)
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
  }

  // --- عملیات کاربر ---
  static Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  static Future<UserModel?> getUserByNationalCode(String code) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'national_code = ?',
      whereArgs: [code],
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  static Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // --- عملیات کتاب ---
  static Future<int> insertBook(BookModel book) async {
    final db = await database;
    return await db.insert('books', book.toMap());
  }

  static Future<List<BookModel>> getAllBooks() async {
    final db = await database;
    final maps = await db.query('books', orderBy: 'title ASC');
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<List<BookModel>> getBooksByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'title ASC',
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<List<BookModel>> getDownloadedBooks() async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'is_downloaded = 1',
      orderBy: 'downloaded_at DESC',
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<int> updateBook(BookModel book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  static Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // --- عملیات امتیاز ---
  static Future<int> insertRating(RatingModel rating) async {
    final db = await database;
    return await db.insert('ratings', rating.toMap());
  }

  static Future<List<RatingModel>> getRatingsForBook(int bookId) async {
    final db = await database;
    final maps = await db.query(
      'ratings',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => RatingModel.fromMap(e)).toList();
  }

  static Future<void> updateBookRating(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as count FROM ratings WHERE book_id = ?',
      [bookId],
    );
    if (result.isNotEmpty) {
      final avg = (result.first['avg_rating'] as num?)?.toDouble() ?? 0.0;
      final count = result.first['count'] as int? ?? 0;
      await db.update(
        'books',
        {'rating': avg, 'rating_count': count},
        where: 'id = ?',
        whereArgs: [bookId],
      );
    }
  }

  // --- عملیات همگام‌سازی ---
  static Future<int> addToSyncQueue(String operation, String payload) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'operation': operation,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  static Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}