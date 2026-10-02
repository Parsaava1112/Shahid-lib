import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/user_model.dart';
import '../../data/models/book_model.dart';
import '../../data/models/rating_model.dart';

class DBHelper {
  static Database? _database;
  static const String _dbName = 'shahid_library.db';
  static const int _dbVersion = 2;

  // ==================== راه‌اندازی ====================

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    // ==================== کاربران ====================
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        national_code TEXT UNIQUE NOT NULL,
        avatar_seed TEXT,
        avatar_style TEXT,
        bio TEXT,
        theme_preference TEXT,
        created_at TEXT
      )
    ''');

    // ==================== کتاب‌ها ====================
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
        downloaded_at TEXT,
        created_at TEXT
      )
    ''');

    // ==================== امتیازات ====================
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

    // ==================== فعالیت‌ها ====================
    await db.execute('''
      CREATE TABLE user_activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER,
        action TEXT NOT NULL,
        minutes_read INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 1,
        last_activity TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ==================== صف همگام‌سازی ====================
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // ==================== پیشرفت مطالعه ====================
    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        current_page INTEGER DEFAULT 1,
        total_pages INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, book_id)
      )
    ''');

    // ==================== نشانک‌ها ====================
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        page INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // ==================== ایندکس‌ها ====================
    await db.execute('CREATE INDEX idx_books_type ON books (type)');
    await db.execute('CREATE INDEX idx_books_category ON books (category)');
    await db.execute('CREATE INDEX idx_ratings_book ON ratings (book_id)');
    await db.execute('CREATE INDEX idx_activities_user ON user_activities (user_id)');
    await db.execute('CREATE INDEX idx_progress_user_book ON reading_progress (user_id, book_id)');
    await db.execute('CREATE INDEX idx_bookmarks_user_book ON bookmarks (user_id, book_id)');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          current_page INTEGER DEFAULT 1,
          total_pages INTEGER DEFAULT 0,
          is_completed INTEGER DEFAULT 0,
          updated_at TEXT NOT NULL,
          UNIQUE(user_id, book_id)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          page INTEGER NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // ==================== عملیات کاربران ====================

  static Future<int> insertUser(UserModel user) async {
    final db = await database;
    final map = user.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(
      'users',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getUserByNationalCode(String code) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'national_code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  static Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  static Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((e) => UserModel.fromMap(e)).toList();
  }

  static Future<int> updateUser(UserModel user) async {
    if (user.id == null) return 0;
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== عملیات کتاب‌ها ====================

  static Future<int> insertBook(BookModel book) async {
    final db = await database;
    final map = book.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(
      'books',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertBooks(List<BookModel> books) async {
    final db = await database;
    final batch = db.batch();
    for (final book in books) {
      final map = book.toMap();
      map['created_at'] = DateTime.now().toIso8601String();
      batch.insert(
        'books',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
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

  static Future<List<BookModel>> getBooksByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'category = ?',
      whereArgs: [category],
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

  static Future<BookModel?> getBookById(int id) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return BookModel.fromMap(maps.first);
    return null;
  }

  static Future<List<BookModel>> searchBooks(String query) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<List<BookModel>> getTopRatedBooks({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'rating > 0',
      orderBy: 'rating DESC',
      limit: limit,
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<int> updateBook(BookModel book) async {
    if (book.id == null) return 0;
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  static Future<int> markBookAsDownloaded(int bookId, String filePath) async {
    final db = await database;
    return await db.update(
      'books',
      {
        'is_downloaded': 1,
        'file_path': filePath,
        'downloaded_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  static Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllBooks() async {
    final db = await database;
    await db.delete('books');
  }

  // ==================== عملیات امتیازات ====================

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

  static Future<double> getAverageRating(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg_rating FROM ratings WHERE book_id = ?',
      [bookId],
    );
    if (result.isNotEmpty) {
      return (result.first['avg_rating'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  static Future<void> updateBookRating(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as count '
      'FROM ratings WHERE book_id = ?',
      [bookId],
    );
    if (result.isNotEmpty) {
      final avg = (result.first['avg_rating'] as num?)?.toDouble() ?? 0.0;
      final count = (result.first['count'] as num?)?.toInt() ?? 0;
      await db.update(
        'books',
        {'rating': avg, 'rating_count': count},
        where: 'id = ?',
        whereArgs: [bookId],
      );
    }
  }

  static Future<int> deleteRating(int id) async {
    final db = await database;
    return await db.delete('ratings', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== عملیات فعالیت‌ها ====================

  static Future<int> recordActivity({
    required int userId,
    int? bookId,
    required String action,
    int minutes = 0,
  }) async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);

    final existing = await db.query(
      'user_activities',
      where: 'user_id = ? AND DATE(last_activity) = ?',
      whereArgs: [userId, todayStr],
      orderBy: 'last_activity DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentMinutes =
          (existing.first['minutes_read'] as num?)?.toInt() ?? 0;
      return await db.update(
        'user_activities',
        {
          'minutes_read': currentMinutes + minutes,
          'last_activity': today.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().substring(0, 10);
      final yesterdayActivity = await db.query(
        'user_activities',
        where: 'user_id = ? AND DATE(last_activity) = ?',
        whereArgs: [userId, yesterdayStr],
        orderBy: 'last_activity DESC',
        limit: 1,
      );

      int streak = 1;
      if (yesterdayActivity.isNotEmpty) {
        streak =
            ((yesterdayActivity.first['current_streak'] as num?)?.toInt() ?? 1) +
                1;
      }

      return await db.insert('user_activities', {
        'user_id': userId,
        'book_id': bookId,
        'action': action,
        'minutes_read': minutes,
        'current_streak': streak,
        'last_activity': today.toIso8601String(),
      });
    }
  }

  static Future<int> getCurrentStreak(int userId) async {
    final db = await database;
    final result = await db.query(
      'user_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_activity DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return (result.first['current_streak'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  static Future<int> getTotalMinutes(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(minutes_read) as total FROM user_activities WHERE user_id = ?',
      [userId],
    );
    if (result.isNotEmpty) {
      return (result.first['total'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  static Future<int> getBooksReadCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT book_id) as count FROM user_activities '
      'WHERE user_id = ? AND action IN ("read", "complete")',
      [userId],
    );
    if (result.isNotEmpty) {
      return (result.first['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getUserActivities(
      int userId) async {
    final db = await database;
    return await db.query(
      'user_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_activity DESC',
    );
  }

  // ==================== صف همگام‌سازی ====================

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

  static Future<void> incrementSyncRetry(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  static Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  // ==================== پیشرفت مطالعه ====================

  static Future<void> saveReadingProgress({
    required int userId,
    required int bookId,
    required int page,
    required int totalPages,
    required bool isCompleted,
  }) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      {
        'user_id': userId,
        'book_id': bookId,
        'current_page': page,
        'total_pages': totalPages,
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int?> getReadingProgress({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    final rows = await db.query(
      'reading_progress',
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [userId, bookId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['current_page'] as int?;
  }

  static Future<Map<String, dynamic>?> getReadingProgressFull({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    final rows = await db.query(
      'reading_progress',
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [userId, bookId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  static Future<List<Map<String, dynamic>>> getAllReadingProgress(
      int userId) async {
    final db = await database;
    return await db.query(
      'reading_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }

  // ==================== نشانک‌ها ====================

  static Future<void> addBookmark({
    required int userId,
    required int bookId,
    required int page,
    String? note,
  }) async {
    final db = await database;
    await db.insert('bookmarks', {
      'user_id': userId,
      'book_id': bookId,
      'page': page,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getBookmarks({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    return await db.query(
      'bookmarks',
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [userId, bookId],
      orderBy: 'page ASC',
    );
  }

  static Future<void> deleteBookmark(int id) async {
    final db = await database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== آمار کلی ====================

  static Future<Map<String, dynamic>> getOverallStats() async {
    final db = await database;
    final books = await db.rawQuery('SELECT COUNT(*) as count FROM books');
    final downloaded = await db.rawQuery(
        'SELECT COUNT(*) as count FROM books WHERE is_downloaded = 1');
    final users = await db.rawQuery('SELECT COUNT(*) as count FROM users');

    return {
      'total_books': (books.first['count'] as num?)?.toInt() ?? 0,
      'downloaded_books': (downloaded.first['count'] as num?)?.toInt() ?? 0,
      'total_users': (users.first['count'] as num?)?.toInt() ?? 0,
    };
  }

  // ==================== پاک‌سازی ====================

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('user_activities');
    await db.delete('ratings');
    await db.delete('sync_queue');
    await db.delete('reading_progress');
    await db.delete('bookmarks');
  }

  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}